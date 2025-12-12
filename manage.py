#!/usr/bin/env python3
import json
import os
import re
import subprocess
from collections import defaultdict
from email.parser import Parser
from email.policy import default
from pathlib import Path

import click
import hcl2
import requests
from cloudflare import Cloudflare

api_token_option = click.option(
    "--api-token", envvar="CLOUDFLARE_API_TOKEN", required=True, help="Cloudflare API token"
)
account_id_option = click.option("-a", "--account-id", required=True, help="Cloudflare account ID")


def get(url, **kwargs):
    response = requests.get(url, **kwargs, timeout=10)
    response.raise_for_status()
    return response.json()


def get_error_messages(result):
    return (line for line in result.stderr.splitlines(keepends=False) if " level=info " not in line)


def run_cf_terraforming(api_token, resource_type, identifier):
    return subprocess.run(  # noqa: S603
        [  # noqa: S607
            "cf-terraforming",
            "generate",
            "--resource-type",
            f"cloudflare_{resource_type}",
            "-a" if resource_type in ACCOUNT_LEVEL else "-z",
            identifier,
        ],
        # PATH is needed if cf-terraforming was installed via Homebrew.
        env={"CLOUDFLARE_API_TOKEN": api_token, "PATH": os.getenv("PATH")},
        capture_output=True,
        text=True,
        check=False,  # errors if HTTP 4XX
    )


@click.group()
def cli():
    pass


@cli.group()
def cloudflare():
    if not Path("terraform").exists():
        raise click.ClickException("run `terraform init`")


@cli.command()
@click.argument("file", type=click.File())
def print_urls_from_email_message(file):
    message = Parser(policy=default).parsestr(file.read())
    print("\n".join(re.findall(r"http[^\s>]+", message.get_body(preferencelist=("plain", "html")).get_content())))


@cloudflare.command()
@api_token_option
@account_id_option
def account_level(api_token, account_id):
    """Print account-level resources"""
    for resource_type in sorted(ACCOUNT_LEVEL_USED):
        result = run_cf_terraforming(api_token, resource_type, account_id)

        if stdout := result.stdout:
            click.echo(stdout)
        else:
            click.secho(f"{resource_type} expected to output", fg="blue", err=True)

        for line in get_error_messages(result):
            click.secho(f"{resource_type}: {line}", fg="red", err=True)


@cloudflare.command()
@api_token_option
@click.option("--defaults", is_flag=True, help="Compare default resource types only")
def zone_level(api_token, defaults):
    """Compare zones' resources"""
    resource_types = ZONE_LEVEL_DEFAULT if defaults else ZONE_LEVEL_USED - {"dns_record"}

    client = Cloudflare(api_token=api_token)
    zones = {zone.name: zone.id for zone in client.zones.list()}

    if not defaults:
        click.secho("page_shield", fg="green")
        resources = defaultdict(list)
        for domain, zone_id in zones.items():
            value = client.page_shield.get(zone_id=zone_id).model_dump()
            value.pop("updated_at")
            resources[json.dumps(value, indent=2)].append(domain)
        if len(resources) == 1:
            click.echo(next(iter(resources)))
        else:
            for value, domains in resources.items():
                click.echo(f"{click.style(', '.join(domains), fg='yellow')}: {value}")

    for resource_type in sorted(resource_types):
        click.secho(resource_type, fg="green")

        resources = defaultdict(list)

        for domain, zone_id in zones.items():
            result = run_cf_terraforming(api_token, resource_type, zone_id)

            for line in get_error_messages(result):
                click.secho(f"{domain}: {line}", fg="red", err=True)

            enabled = True
            if data := hcl2.loads(result.stdout):
                for resource in data["resource"]:
                    for value in resource[f"cloudflare_{resource_type}"].values():
                        for key in ("zone_id", "hosts"):
                            value.pop(key, None)
                        if rules := value.get("rules"):
                            for rule in rules:
                                for key in ("last_updated", "ref", "version"):
                                    rule.pop(key)
                        if defaults and len(value) == 1:
                            if value.get("enabled") is False:
                                enabled = value.pop("enabled")
                            elif domain in value.get("name", ""):  # email_routing_dns
                                value.pop("name")
                        if value:
                            resources[json.dumps(value, indent=2)].append(domain)

        match len(resources):
            case 0:
                if not enabled:
                    click.secho("disabled", fg="yellow")
            case 1:
                click.echo(next(iter(resources)))
            case _:
                for value, domains in resources.items():
                    click.echo(f"{click.style(', '.join(domains), fg='yellow')}: {value}")


@cloudflare.command()
@api_token_option
@account_id_option
def unused(api_token, account_id):
    """Confirm unused resources"""
    sets = (
        ("BAD_REQUEST", BAD_REQUEST, " 400 Bad Request "),
        ("DEPRECATED", DEPRECATED, ' is deprecated. The terraform config might not be generated."'),
        ("FORBIDDEN", FORBIDDEN, " 403 Forbidden "),
        ("UNAUTHORIZED", UNAUTHORIZED, " 401 Unauthorized "),
        ("UNSUPPORTED", UNSUPPORTED, ' msg="Unsupported terraform v5 provider resource" '),
    )

    def _unused(result):
        for name, values, substring in sets:
            if resource_type in values and substring not in result.stderr:
                click.secho(f"{resource_type} not expected in {name}", fg="blue")

        if stdout := result.stdout:
            click.secho(f"{resource_type} not expected to output", fg="blue")
            click.echo(stdout)

        for line in get_error_messages(result):
            # Ignore expected messages.
            if (
                ' msg="No resource IDs defined in Terraform for resource ' not in line
                and not re.search(r'^no resources of type "\w+" found to generate$', line)
                and not any(substring not in line or resource_type not in values for (_, values, substring) in sets)
            ):
                click.secho(f"{resource_type}: {line}", fg="red")

    # Check that all resource types are recognized.
    latest_version_id = get(
        "https://registry.terraform.io/v2/providers/cloudflare/cloudflare", params={"include": "provider-versions"}
    )["data"]["relationships"]["provider-versions"]["data"][-1]["id"]
    data = get(f"https://registry.terraform.io/v2/provider-versions/{latest_version_id}?include=provider-docs")
    resource_types = {r["attributes"]["title"] for r in data["included"] if r["attributes"]["category"] == "resources"}

    if unrecognized := resource_types - RESOURCE_TYPES:
        click.secho(f"Terraform resource types not named in manage.py: {', '.join(sorted(unrecognized))}", fg="yellow")
    if orphaned := RESOURCE_TYPES - resource_types:
        click.secho(f"manage.py resource types not found in Terraform: {', '.join(orphaned)}", fg="yellow")

    # Check that the resources types are unused.
    client = Cloudflare(api_token=api_token)
    zone_id = client.zones.list(name="open-contracting.org").result[0].id

    for resource_type in sorted(ACCOUNT_LEVEL - ACCOUNT_LEVEL_USED - ACCOUNT_LEVEL_IGNORE):
        _unused(run_cf_terraforming(api_token, resource_type, account_id))
    for resource_type in sorted(ZONE_LEVEL - ZONE_LEVEL_USED - ZONE_LEVEL_DEFAULT):
        _unused(run_cf_terraforming(api_token, resource_type, zone_id))


ACCOUNT_LEVEL_USED = {
    "account_dns_settings",
    "custom_pages",
    "pages_project",
    "registrar_domain",
    "turnstile_widget",
    "zone",
    "web_analytics_site",
}
ACCOUNT_LEVEL_IGNORE = {
    "account",
    "account_subscription",
    "account_member",
}
ACCOUNT_LEVEL_FORBIDDEN = {
    "account_token",
    "api_token",
    "user",
    "workers_for_platforms_dispatch_namespace",  # https://developers.cloudflare.com/cloudflare-for-platforms/workers-for-platforms/reference/how-workers-for-platforms-works/
}
ACCOUNT_LEVEL_UNUSED = {
    "account_dns_settings_internal_view",  # https://developers.cloudflare.com/dns/internal-dns/
    "pages_domain",  # https://developers.cloudflare.com/rules/origin-rules/tutorials/point-to-pages-with-custom-domain/
}
ACCOUNT_LEVEL_DEPRECATED = {
    "filter",
    "firewall_rule",
    "rate_limit",
}

ZONE_LEVEL_USED = {
    "argo_tiered_caching",  # https://developers.cloudflare.com/cache/how-to/tiered-cache/
    "bot_management",  # https://developers.cloudflare.com/bots/get-started/bot-management/
    "certificate_pack",  # https://developers.cloudflare.com/ssl/edge-certificates/custom-certificates/#certificate-packs
    "dns_record",
    "managed_transforms",
    "ruleset",
    "tiered_cache",
    "total_tls",
    "url_normalization_settings",
    "zone_dns_settings",
    "zone_dnssec",
    "zone_hold",  # https://developers.cloudflare.com/fundamentals/account/account-security/zone-holds/
}
# Child resources exist (e.g. "enabled = false"), but parent resources don't.
ZONE_LEVEL_DEFAULT = {
    "api_shield_schema_validation_settings",
    "authenticated_origin_pulls_settings",
    "email_routing_catch_all",
    "email_routing_dns",
    "email_routing_rule",
    "email_routing_settings",
    "leaked_credential_check",
    "waiting_room_settings",
}
ZONE_LEVEL_BAD_REQUEST = {
    "content_scanning_expression",
    "custom_ssl",  # https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/#custom-ssltls
    "leaked_credential_check_rule",  # https://developers.cloudflare.com/waf/detections/leaked-credentials/
    "origin_ca_certificate",  # https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/
    "zone_subscription",  # https://developers.cloudflare.com/tenant/how-to/manage-subscriptions/
    # Cloudforce One https://developers.cloudflare.com/security-center/cloudforce-one/
    "cloudforce_one_request_priority",
    "cloudforce_one_request_asset",
}
ZONE_LEVEL_UNAUTHORIZED = {
    "argo_smart_routing",  # https://developers.cloudflare.com/argo-smart-routing/
    "custom_hostname_fallback_origin",
    "logpull_retention",
    "logpush_job",
}
ZONE_LEVEL_FORBIDDEN = {
    "api_shield",
    "api_shield_discovery_operation",
    "regional_hostname",  # https://developers.cloudflare.com/data-localization/regional-services/
    "regional_tiered_cache",  # https://developers.cloudflare.com/smart-shield/configuration/regional-tiered-cache/
    "spectrum_application",  # https://developers.cloudflare.com/spectrum/
    "zone_cache_reserve",  # https://developers.cloudflare.com/cache/advanced-configuration/cache-reserve/
    "zone_cache_variants",  # https://developers.cloudflare.com/cache/advanced-configuration/serve-tailored-content/
}
ZONE_LEVEL_UNUSED = {
    "zone_setting",  # https://developers.cloudflare.com/terraform/tutorial/configure-https-settings/#1-create-zone-setting-configuration
    #
    # Application performance https://developers.cloudflare.com/directory/?product-group=Application+performance
    #
    "healthcheck",  # https://developers.cloudflare.com/health-checks/
    "observatory_scheduled_test",  # https://developers.cloudflare.com/speed/observatory/
    "web_analytics_rule",  # https://developers.cloudflare.com/web-analytics/configuration-options/rules/
    "web3_hostname",  # https://developers.cloudflare.com/web3/
    # DNS zone transfers https://developers.cloudflare.com/dns/zone-setups/zone-transfers/
    "dns_zone_transfers_acl",
    "dns_zone_transfers_incoming",
    "dns_zone_transfers_outgoing",
    "dns_zone_transfers_peer",
    "dns_zone_transfers_tsig",
    # Load balancing https://developers.cloudflare.com/load-balancing/
    "load_balancer",
    "load_balancer_monitor",
    "load_balancer_pool",
    # Waiting Room https://developers.cloudflare.com/waiting-room/
    "waiting_room",
    "waiting_room_event",
    "waiting_room_rules",
    #
    # Application security https://developers.cloudflare.com/directory/?product-group=Application+security
    #
    "dns_firewall",  # https://developers.cloudflare.com/dns/dns-firewall/
    "page_shield_policy",  # https://developers.cloudflare.com/page-shield/
    # API Shield https://developers.cloudflare.com/api-shield/
    "api_shield_operation",
    "api_shield_operation_schema_validation_settings",
    "api_shield_schema",
    # SSL/TLS
    "authenticated_origin_pulls",  # https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/
    "authenticated_origin_pulls_certificate",
    "hostname_tls_setting",  # https://developers.cloudflare.com/ssl/edge-certificates/additional-options/minimum-tls/#per-hostname
    "keyless_certificate",  # https://developers.cloudflare.com/ssl/keyless-ssl/
    "mtls_certificate",  # https://developers.cloudflare.com/ssl/client-certificates/
    # Web Application Firewall
    "access_rule",  # https://developers.cloudflare.com/waf/tools/ip-access-rules/
    "content_scanning",  # https://developers.cloudflare.com/waf/detections/malicious-uploads/
    "list",  # https://developers.cloudflare.com/waf/tools/lists/lists-api/
    "list_item",
    "user_agent_blocking_rule",  # https://developers.cloudflare.com/waf/tools/user-agent-blocking/
    "zone_lockdown",  # https://developers.cloudflare.com/waf/tools/zone-lockdown/
    #
    # Cloudflare One https://developers.cloudflare.com/directory/?product-group=Cloudflare+One
    #
    # Email security https://developers.cloudflare.com/cloudflare-one/email-security/
    "email_security_block_sender",
    "email_security_impersonation_registry",
    "email_security_trusted_domains",
    #
    # Core platform https://developers.cloudflare.com/directory/?product-group=Core+platform
    #
    # Notifications https://developers.cloudflare.com/notifications/
    "notification_policy",
    "notification_policy_webhooks",
    # Rules
    "snippet_rules",
    #
    # Developer platform https://developers.cloudflare.com/directory/?product-group=Developer+platform
    #
    "custom_hostname",  # https://developers.cloudflare.com/cloudflare-for-platforms/cloudflare-for-saas/domain-support/
    "d1_database",  # https://developers.cloudflare.com/d1/
    "hyperdrive_config",  # https://developers.cloudflare.com/hyperdrive/
    "workers_route",  # https://developers.cloudflare.com/workers/configuration/routing/
    # Calls https://developers.cloudflare.com/realtime/
    "calls_sfu_app",
    "calls_turn_app",
    # Email routing https://developers.cloudflare.com/email-routing/
    "email_routing_address",
    # Images https://developers.cloudflare.com/images/
    "image",
    "image_variant",
    # Queue https://developers.cloudflare.com/queues/
    "queue",
    "queue_consumer",
    # R2 https://developers.cloudflare.com/r2/
    "r2_bucket",
    "r2_bucket_cors",
    "r2_bucket_event_notification",
    "r2_bucket_lifecycle",
    "r2_bucket_lock",
    "r2_bucket_sippy",
    "r2_custom_domain",
    "r2_managed_domain",
    # Stream https://developers.cloudflare.com/stream/
    "stream",
    "stream_audio_track",
    "stream_caption_language",
    "stream_download",
    "stream_key",
    "stream_live_input",
    "stream_watermark",
    "stream_webhook",
    #
    # Network security https://developers.cloudflare.com/directory/?product-group=Network+security
    #
    # Magic Network Monitoring https://developers.cloudflare.com/magic-network-monitoring/
    "magic_network_monitoring_configuration",
    "magic_network_monitoring_rule",
    # Magic Transit https://developers.cloudflare.com/magic-transit/
    "magic_transit_connector",
    "magic_transit_site",
    "magic_transit_site_acl",
    "magic_transit_site_lan",
    "magic_transit_site_wan",
    # Magic WAN https://developers.cloudflare.com/magic-wan/
    "magic_wan_gre_tunnel",
    "magic_wan_ipsec_tunnel",
    "magic_wan_static_route",
    # BYOIP
    "address_map",  # https://developers.cloudflare.com/byoip/address-maps/
    "byo_ip_prefix",  # https://developers.cloudflare.com/byoip/
}
ZONE_LEVEL_DEPRECATED = {
    "api_shield_discovery_operation",
    "snippets",
}

UNSUPPORTED = {
    # Accounts https://developers.cloudflare.com/fundamentals/account/
    "account",
    "account_member",
    "account_subscription",
    # API Shield
    "schema_validation_operation_settings",  # https://developers.cloudflare.com/api-shield/security/schema-validation/
    "schema_validation_schemas",
    "schema_validation_settings",
    "token_validation_config",  # https://developers.cloudflare.com/api-shield/security/jwt-validation/
    "token_validation_rules",
    # Cloudforce One
    "cloudforce_one_request",
    "cloudforce_one_request_message",
    # Core platform
    "sso_connector",  # https://developers.cloudflare.com/fundamentals/manage-members/dashboard-sso/
    # Developer platform
    "connectivity_directory_service",  # https://developers.cloudflare.com/workers-vpc/configuration/vpc-services/
    "workflow",  # https://developers.cloudflare.com/workflows/
    # Logs https://developers.cloudflare.com/logs/
    "logpush_ownership_challenge",
    # Organizations https://developers.cloudflare.com/fundamentals/organizations/
    "organization",
    "organization_profile",
    # Rules
    "cloud_connector_rules",  # https://developers.cloudflare.com/rules/cloud-connector/
    "snippet",  # https://developers.cloudflare.com/rules/snippets/
    # SSL/TLS
    "universal_ssl_setting",  # https://developers.cloudflare.com/ssl/edge-certificates/universal-ssl/enable-universal-ssl/
    # Workers https://developers.cloudflare.com/workers/
    "worker",
    "worker_version",  # https://developers.cloudflare.com/workers/configuration/versions-and-deployments/#versions
    "workers_cron_trigger",  # https://developers.cloudflare.com/workers/configuration/cron-triggers/
    "workers_custom_domain",  # https://developers.cloudflare.com/workers/configuration/routing/custom-domains/
    "workers_deployment",  # https://developers.cloudflare.com/workers/configuration/versions-and-deployments/#deployments
    "workers_script",  # https://developers.cloudflare.com/workers/static-assets/routing/worker-script/
    "workers_script_subdomain",  # https://developers.cloudflare.com/workers/configuration/routing/workers-dev/#configure-workersdev
    # Workers KV https://developers.cloudflare.com/kv/
    "workers_kv",
    "workers_kv_namespace",
    # Zero Trust https://www.cloudflare.com/en-us/zero-trust/
    "zero_trust_access_ai_controls_mcp_portal",
    "zero_trust_access_ai_controls_mcp_server",
    "zero_trust_access_application",
    "zero_trust_access_custom_page",
    "zero_trust_access_group",
    "zero_trust_access_identity_provider",
    "zero_trust_access_infrastructure_target",
    "zero_trust_access_key_configuration",
    "zero_trust_access_mtls_certificate",
    "zero_trust_access_mtls_hostname_settings",
    "zero_trust_access_policy",
    "zero_trust_access_service_token",
    "zero_trust_access_short_lived_certificate",
    "zero_trust_access_tag",
    "zero_trust_device_custom_profile",
    "zero_trust_device_custom_profile_local_domain_fallback",
    "zero_trust_device_default_profile",
    "zero_trust_device_default_profile_certificates",
    "zero_trust_device_default_profile_local_domain_fallback",
    "zero_trust_device_managed_networks",
    "zero_trust_device_posture_integration",
    "zero_trust_device_posture_rule",
    "zero_trust_device_settings",
    "zero_trust_dex_test",
    "zero_trust_dlp_custom_entry",
    "zero_trust_dlp_custom_profile",
    "zero_trust_dlp_dataset",
    "zero_trust_dlp_entry",
    "zero_trust_dlp_integration_entry",
    "zero_trust_dlp_predefined_entry",
    "zero_trust_dlp_predefined_profile",
    "zero_trust_dns_location",
    "zero_trust_gateway_certificate",
    "zero_trust_gateway_logging",
    "zero_trust_gateway_policy",
    "zero_trust_gateway_proxy_endpoint",
    "zero_trust_gateway_settings",
    "zero_trust_list",
    "zero_trust_network_hostname_route",
    "zero_trust_organization",
    "zero_trust_risk_behavior",
    "zero_trust_risk_scoring_integration",
    "zero_trust_tunnel_cloudflared",
    "zero_trust_tunnel_cloudflared_config",
    "zero_trust_tunnel_cloudflared_route",
    "zero_trust_tunnel_cloudflared_virtual_network",
    "zero_trust_tunnel_warp_connector",
    # Deprecated
    "firewall_rule",
}

ACCOUNT_LEVEL = (
    ACCOUNT_LEVEL_DEPRECATED
    | ACCOUNT_LEVEL_FORBIDDEN
    | ACCOUNT_LEVEL_IGNORE
    | ACCOUNT_LEVEL_UNUSED
    | ACCOUNT_LEVEL_USED
    | {
        # "… endpoint does not support account owned tokens" https://developers.cloudflare.com/fundamentals/api/get-started/account-owned-tokens/#compatibility-matrix
        "page_rule",  # https://developers.cloudflare.com/rules/page-rules/
    }
)

ZONE_LEVEL = (
    ZONE_LEVEL_BAD_REQUEST
    | ZONE_LEVEL_DEFAULT
    | ZONE_LEVEL_DEPRECATED
    | ZONE_LEVEL_FORBIDDEN
    | ZONE_LEVEL_UNAUTHORIZED
    | ZONE_LEVEL_UNUSED
    | ZONE_LEVEL_USED
)

RESOURCE_TYPES = ACCOUNT_LEVEL | ZONE_LEVEL | UNSUPPORTED
BAD_REQUEST = ZONE_LEVEL_BAD_REQUEST
FORBIDDEN = ACCOUNT_LEVEL_FORBIDDEN | ZONE_LEVEL_FORBIDDEN
DEPRECATED = ACCOUNT_LEVEL_DEPRECATED | ZONE_LEVEL_DEPRECATED
UNAUTHORIZED = ZONE_LEVEL_UNAUTHORIZED

if __name__ == "__main__":
    cli()
