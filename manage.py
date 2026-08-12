#!/usr/bin/env python3
import csv
import difflib
import hashlib
import json
import os
import re
import secrets
import string
import subprocess
import sys
from collections import defaultdict
from email.parser import Parser
from email.policy import default
from itertools import islice
from pathlib import Path

import click
import hcl2
import requests
from cloudflare import Cloudflare
from rich.console import Console
from rich.syntax import Syntax

console = Console()

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


def print_resources(resources, *, disabled=True, default=False):
    match len(resources):
        case 0:
            if disabled:
                click.secho("disabled", fg="yellow")
            elif default:
                click.secho("default", fg="yellow")
        case 1:
            click.echo(next(iter(resources)))
        case _:
            for value, domains in resources.items():
                click.echo(f"{click.style(', '.join(domains), fg='yellow')}: {value}")


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


def salt_ssh(*args):
    return subprocess.run(["./run.py", *args], check=True, text=True, stdout=subprocess.PIPE).stdout  # noqa: S603 # trusted input


def gam(*args, check=True):
    result = subprocess.run(["gam", *args], capture_output=True, text=True, check=False)  # noqa: S603 S607
    if check and result.returncode:
        raise click.ClickException(result.stderr.strip())
    return result


def sha256_crypt(password, salt):
    """
    Return the SHA-256 crypt checksum.

    https://www.akkadia.org/drepper/SHA-crypt.txt
    """
    b = hashlib.sha256(password + salt + password).digest()

    initial = password + salt + b * (len(password) // 32) + b[: len(password) % 32]
    length = len(password)
    while length:
        initial += b if length & 1 else password
        length >>= 1
    a = hashlib.sha256(initial).digest()

    sequence = hashlib.sha256(password * len(password)).digest()
    p = (sequence * (len(password) // 32 + 1))[: len(password)]
    sequence = hashlib.sha256(salt * (16 + a[0])).digest()
    s = (sequence * (len(salt) // 32 + 1))[: len(salt)]

    c = a
    for i in range(MYSQL_ROUNDS):
        c = hashlib.sha256(
            (p if i % 2 else c) + (s if i % 3 else b"") + (p if i % 7 else b"") + (c if i % 2 else p)
        ).digest()
    return c


def sha256_crypt_encode(digest):
    """
    Return the checksum in SHA-crypt's base64 encoding.

    Equivalent to passlib's `h64.encode_transposed_bytes`.

    https://www.akkadia.org/drepper/SHA-crypt.txt
    """
    characters = []
    for high, middle, low in MYSQL_ORDER[:-1]:
        value = (digest[high] << 16) | (digest[middle] << 8) | digest[low]
        for _ in range(4):
            characters.append(MYSQL_B64_ALPHABET[value & 0x3F])
            value >>= 6
    high, low = MYSQL_ORDER[-1]
    value = (digest[high] << 8) | digest[low]
    for _ in range(3):
        characters.append(MYSQL_B64_ALPHABET[value & 0x3F])
        value >>= 6
    return "".join(characters)


@click.group()
def cli():
    pass


@cli.group()
def cloudflare():
    """Cloudflare command group"""
    if not Path("terraform").exists():
        raise click.ClickException("run `terraform init`")


@cli.command()
@click.argument("file", type=click.File())
def print_urls_from_email_message(file):
    """Print URLs from an email message that might be suspicious"""
    message = Parser(policy=default).parsestr(file.read())
    print("\n".join(re.findall(r"http[^\s>]+", message.get_body(preferencelist=("plain", "html")).get_content())))


@cloudflare.command()
@api_token_option
@account_id_option
def account(api_token, account_id):
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
def zones(api_token, defaults):
    """Compare zones' resources"""
    resource_types = ZONE_LEVEL_DEFAULT if defaults else ZONE_LEVEL_USED - {"dns_record"}

    client = Cloudflare(api_token=api_token)
    zone_ids = {zone.name: zone.id for zone in client.zones.list()}

    if not defaults:
        click.secho("page_shield", fg="green")
        resources = defaultdict(list)
        for domain, zone_id in zone_ids.items():
            value = client.page_shield.get(zone_id=zone_id).model_dump()
            value.pop("updated_at")
            resources[json.dumps(value, indent=2)].append(domain)
        print_resources(resources)

        for setting_id in (
            # SSL/TLS
            "ssl",
            "ciphers",
            "always_use_https",
            "min_tls_version",
            "security_header",
            # Speed > Settings
            "speed_brain",
            "early_hints",
            "0rtt",
            # Caching > Configuration
            "browser_cache_ttl",
        ):
            click.secho(f"zone_settings_{setting_id}", fg="green")
            resources = defaultdict(list)
            for domain, zone_id in zone_ids.items():
                value = client.zones.settings.get(setting_id, zone_id=zone_id).model_dump()
                for key in ("id", "editable", "modified_on"):  # id = setting_id, editable = true
                    value.pop(key)
                value.pop("cf_zone_tag", None)
                if len(value) == 1:
                    value = value.pop("value")
                resources[json.dumps(value, indent=2)].append(domain)
            print_resources(resources)

    for resource_type in sorted(resource_types):
        click.secho(resource_type, fg="green")

        resources = defaultdict(list)

        for domain, zone_id in zone_ids.items():
            result = run_cf_terraforming(api_token, resource_type, zone_id)

            for line in get_error_messages(result):
                click.secho(f"{domain}: {line}", fg="red", err=True)

            disabled = False
            default = False
            if data := hcl2.loads(result.stdout):
                for resource in data["resource"]:
                    for value in resource[f"cloudflare_{resource_type}"].values():
                        for key in ("zone_id", "hosts"):
                            value.pop(key, None)
                        if rules := value.get("rules"):
                            for rule in rules:
                                for key in ("last_updated", "ref", "version"):
                                    rule.pop(key)
                        if not value:
                            default = True
                        elif len(value) == 1:
                            if value.get("enabled") is False:
                                value.pop("enabled")
                                disabled = False
                            elif value.get("status") == "disabled":
                                value.pop("status")
                                disabled = False
                            elif domain in value.get("name", ""):  # email_routing_dns
                                value.pop("name")
                                default = True
                        if value:
                            resources[json.dumps(value, indent=2)].append(domain)

        print_resources(resources, disabled=disabled, default=default)


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


@cli.command()
@click.argument("file", type=click.File())
def google_calendar(file):
    """Report the secondary calendars in FILE that are owned by archived users."""
    result = gam("print", "users", "query", "isArchived=True", "fields", "primaryEmail")
    archived_users = {row["primaryEmail"] for row in csv.DictReader(result.stdout.splitlines())}

    summaries = {}
    data_owners = {}
    for row in csv.DictReader(file):
        cid = row["calendarId"]
        # Secondary calendars end in "@group.calendar.google.com".
        if cid.endswith("@group.calendar.google.com"):
            summaries[cid] = row["summary"] or row["summaryOverride"]
            # A calendar's data owner is reported to its owners and writers only.
            if row["dataOwner"]:
                data_owners[cid] = [row["dataOwner"]]

    # If a calendar's subscribers are all readers, read its ACL, instead.
    unknown = []
    calendar_ids = sorted(summaries.keys() - data_owners.keys())
    with click.progressbar(calendar_ids, label="Reading calendars' ACLs", file=sys.stderr) as calendar_ids:
        for cid in calendar_ids:
            result = gam("calendar", cid, "showacl", check=False)
            if not result.returncode:
                # An owner in the ACL isn't necessarily the data owner, but it's the only evidence available.
                data_owners[cid] = re.findall(rf"Scope: user:(\S+@{re.escape(DOMAIN)}), Role: owner", result.stdout)
            # A calendar is not at risk if it is deleted ("Does not exist") or outside the domain ("Forbidden").
            elif not re.search("Show Failed: (Does not exist|Forbidden)", result.stderr):
                unknown.append((cid, " ".join(result.stderr.split())))

    archived = [
        (cid, owners) for cid, owners in data_owners.items() if any(email in archived_users for email in owners)
    ]

    if unknown:
        click.secho(f"\n{len(unknown)} calendars with unknown owners", fg="red")
        for cid, message in unknown:
            click.echo(f"  {click.style(summaries[cid], fg='yellow')} <{cid}>\n    {message}")

    if archived:
        click.secho("Transfer these calendars, if appropriate, before deleting the archived owner", fg="red")
        for cid, owners in archived:
            click.echo(f"  {click.style(summaries[cid], fg='yellow')} owned by {', '.join(owners)}")
            click.echo(f"    gam calendars {cid} transfer {TRANSFER}@{DOMAIN}")
    else:
        click.secho("No calendars are owned by archived users", fg="green")


@cli.command()
@click.argument("file", type=click.File())
@click.argument("shortcuts", type=click.File())
def google_drive(file, shortcuts):
    """Report the files and folders in FILE with shortcuts in SHORTCUTS."""
    # The "List the user's files in Drive" command from docs/deploy/services/google.rst guarantees a single "Owner".
    user = ""
    names = {}
    folder_ids = set()
    for row in csv.DictReader(file):
        file_id = row["id"]
        user = row["Owner"]
        names[file_id] = row["name"]
        if row["mimeType"] == "application/vnd.google-apps.folder":
            folder_ids.add(file_id)

    result = gam("print", "shareddrives", "fields", "id,name")
    drive_names = {row["id"]: row["name"] for row in csv.DictReader(result.stdout.splitlines())}

    def drive_label(drive_id):
        return drive_names.get(drive_id, "Unknown shared drive")

    # { File ID: { External Drive ID: Internal users who can read an external shortcut to the file } }
    external = defaultdict(lambda: defaultdict(set))
    # { Shortcut Drive ID: { File ID: { Shortcut Parent ID: Shortcut IDs } } }
    drives = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    # { User email: The folder IDs to which the user shortcuts }
    users = defaultdict(set)
    # { Shortcut ID: ( File ID, Shortcut Drive ID ) }
    unresolved_shortcuts = {}
    seen_shortcut_ids = set()
    for row in csv.DictReader(shortcuts):
        shortcut_id = row["id"]
        drive_id = row["driveId"]
        folder_id = row["parents.0.id"]
        target_id = row["shortcutDetails.targetId"]
        owner = row["owners.0.emailAddress"]
        member = row["Owner"]  # the user whose Drive was read

        # The "Write the shortcuts in active users' My Drive and shared drives" command can write the same shortcut
        # many times. Skip a shortcut to another user's file, or a shortcut that was already seen.
        if target_id not in names or shortcut_id in seen_shortcut_ids:
            continue

        if drive_id == OCP_ARCHIVE_SHARED_DRIVE_ID:
            seen_shortcut_ids.add(shortcut_id)
            # Ignore shortcuts created by the "Move the user's My Drive" command (`createshortcutsfornonmovablefiles`).
        elif drive_id:
            if drive_id not in drive_names:
                seen_shortcut_ids.add(shortcut_id)
                external[target_id][drive_id].add(member)
            elif folder_id:
                seen_shortcut_ids.add(shortcut_id)
                drives[drive_id][target_id][folder_id].append(shortcut_id)
            else:
                # Don't add the shortcut to `seen_shortcut_ids`, so that another row can still resolve it.
                unresolved_shortcuts[shortcut_id] = (target_id, drive_id)
        elif target_id in folder_ids and owner != user:  # no need to notify the user to be deleted
            seen_shortcut_ids.add(shortcut_id)
            users[owner].add(target_id)

    # A shortcut is unresolved if no member can read its folder.
    # { File ID: The internal drive IDs with a shortcut to the file, in which the folder is unknown }
    unresolved = defaultdict(set)
    for shortcut_id, (file_id, drive_id) in unresolved_shortcuts.items():
        if shortcut_id not in seen_shortcut_ids:
            unresolved[file_id].add(drive_id)

    if not external and not drives and not users and not unresolved:
        click.secho("No shortcuts point to the user's files", fg="green")
        return

    # { File ID: ( Shortcut Drive ID, Shortcut Parent ID ) pairs }
    destinations = defaultdict(set)
    for drive_id, files in drives.items():
        for file_id, parents in files.items():
            for parent_id in parents:
                destinations[file_id].add((drive_id, parent_id))

    if drives:
        click.secho(f"{len(destinations)} of the user's files have shortcuts in shared drives:", fg="red")
        for drive_id, files in drives.items():
            click.secho(f"\n{drive_label(drive_id)} <{drive_id}>", fg="red")
            for file_id in files:
                suffix = click.style(" (folder)", fg="yellow") if file_id in folder_ids else ""
                if len(destinations[file_id]) > 1:
                    suffix += click.style(f" has shortcuts in {len(destinations[file_id])} folders", fg="yellow")
                click.echo(f"  {names[file_id]}{suffix}")

    if unresolved:
        click.secho("\nWARNING: These files have shortcuts in unreadable folders of:", fg="red")
        for file_id in unresolved:
            drive_labels = ", ".join(f"{drive_label(drive_id)} <{drive_id}>" for drive_id in unresolved[file_id])
            click.echo(f"  {names[file_id]}: {drive_labels}")
        click.secho("\nBecome a Manager of these shared drives:", fg="green")
        unreadable_drive_ids = {drive_id for drive_ids in unresolved.values() for drive_id in drive_ids}
        for drive_id in unreadable_drive_ids:
            click.echo(f"\ngam add drivefileacl {drive_id} user $admin@{DOMAIN} role manager")
        click.echo("\nThen, re-write the shortcuts file, and re-run this command. After the files are moved:")
        for drive_id in unreadable_drive_ids:
            click.echo(f"gam delete drivefileacl {drive_id} $admin@{DOMAIN}")

    if external:
        click.secho("\nWARNING: These files have shortcuts in external shared drives:", fg="red")
        for file_id, members_by_drive in external.items():
            suffix = click.style(" (folder)", fg="yellow") if file_id in folder_ids else ""
            click.echo(f"  {names[file_id]}{suffix}")
            for drive_id, members in members_by_drive.items():
                click.echo(f"    {drive_id} (ask {', '.join(members)})")
        click.echo("Ask to notify the external users, or move the file where the external users can read it.")

    if users:
        click.secho("\nWARNING: Notify these users that their shortcuts to these folders will break:", fg="red")
        for email, file_ids in users.items():
            click.secho(f"\n{email}", fg="yellow")
            for file_id in file_ids:
                click.echo(f"  {names[file_id]}")

    for drive_id, files in drives.items():
        moves = defaultdict(list)
        deletes = []
        for file_id, shortcuts_by_parent in files.items():
            if len(destinations[file_id]) == 1:
                for parent_id, shortcut_ids in shortcuts_by_parent.items():
                    moves[parent_id].append(file_id)
                    deletes.extend(shortcut_ids)
        if moves:
            click.secho(f"\nMove the files next to their shortcuts in {drive_label(drive_id)}:", fg="green")
            click.echo(f"\ngam add drivefileacl {drive_id} user {user} role manager")
            for parent_id, file_ids in moves.items():
                click.echo(
                    f"gam user {user} move drivefile ids {','.join(file_ids)} shareddriveparentid {parent_id} "
                    f"duplicatefiles uniquename summary showpermissionmessages"
                )
            click.echo(f"\ngam user {user} delete drivefile ids {','.join(deletes)}")
            click.echo(f"\ngam delete drivefileacl {drive_id} {user}")

    choices = [file_id for file_id, pairs in destinations.items() if len(pairs) > 1]
    for file_id in choices:
        click.secho(f"\nMove {names[file_id]} to one of its {len(destinations[file_id])} folders:", fg="green")
        for drive_id, parent_id in destinations[file_id]:
            click.echo(f"\n# in {drive_label(drive_id)}: https://drive.google.com/drive/folders/{parent_id}")
            click.echo(f"gam add drivefileacl {drive_id} user {user} role manager")
            click.echo(
                f"gam user {user} move drivefile {file_id} shareddriveparentid {parent_id} "
                f"duplicatefiles uniquename summary showpermissionmessages"
            )
            click.echo(f"gam user {user} delete drivefile ids {','.join(drives[drive_id][file_id][parent_id])}")
            click.echo(f"gam delete drivefileacl {drive_id} {user}")


@cli.command()
@click.argument("local", type=click.Path(exists=True, path_type=Path))
@click.argument("remote")
def diff(local, remote):
    """
    Compare a remote file across all servers against a local file.

    Example: manage.py diff firewall-settings.typical /home/sysadmin-tools/firewall-settings.local
    """
    expected = local.read_text().splitlines()

    stdout = salt_ssh("*", "file.read", remote)

    target = None
    contents = defaultdict(list)
    for line in stdout.splitlines():
        if line.startswith("    "):
            contents[target].append(line[4:])
        else:
            target = line[:-1]  # trailing colon

    for target, actual in contents.items():
        if actual == expected:
            click.secho(f"{target}: no changes", fg="green")
        else:
            click.secho(f"{target}:", fg="yellow")
            console.print(
                # Remove the file headers ("---", "+++").
                Syntax("\n".join(islice(difflib.unified_diff(expected, actual, n=0, lineterm=""), 2, None)), "diff")
            )


@cli.command()
@click.option("--check", "expected", help="Report whether the password matches this hash")
def mysql_hash(expected):
    """Generate a caching_sha2_password MySQL hash."""
    # Prompt on standard error, so that standard output contains the hash only.
    password = (
        click.prompt("Password", hide_input=True, err=True) if sys.stdin.isatty() else sys.stdin.read().rstrip("\n")
    )
    if not password:
        raise click.ClickException("The password must not be empty")

    if expected:
        if not re.fullmatch(r"\$A\$\d{3}\$.{20}.{43}", expected):
            raise click.ClickException("The hash is malformed")
        salt = expected[MYSQL_PREFIX_LENGTH : MYSQL_PREFIX_LENGTH + MYSQL_SALT_LENGTH]
    else:
        salt = "".join(secrets.choice(MYSQL_SALT_ALPHABET) for _ in range(MYSQL_SALT_LENGTH))

    checksum = sha256_crypt_encode(sha256_crypt(password.encode(), salt.encode()))
    actual = f"$A${MYSQL_ROUNDS // 1000:03d}${salt}{checksum}"

    if expected:
        if actual != expected:
            raise click.ClickException("The password doesn't match the hash")
        click.secho("The password matches the hash", fg="green", err=True)
    else:
        click.echo(actual)


DOMAIN = "open-contracting.org"
TRANSFER = "operations"
OCP_ARCHIVE_SHARED_DRIVE_ID = "0AKb5W5k2WH46Uk9PVA"

MYSQL_PREFIX_LENGTH = len("$A$005$")
# https://github.com/mysql/mysql-server/blob/8.0/include/crypt_genhash_impl.h
MYSQL_ROUNDS = 5000  # ROUNDS_DEFAULT
# https://www.akkadia.org/drepper/SHA-crypt.txt has "the salt string truncated to 16 characters", so implementations
# like passlib.hash.sha256_crypt truncate - but MySQL doesn't.
MYSQL_SALT_LENGTH = 20  # CRYPT_SALT_LENGTH
# See "static const char b64t[64]" at https://www.akkadia.org/drepper/SHA-crypt.txt
MYSQL_B64_ALPHABET = "./" + string.digits + string.ascii_uppercase + string.ascii_lowercase
# MySQL uses raw bytes (1-127) excluding $, but unprintable characters must be escaped in YAML and SQL. Use printable
# characters (33-126) less those that need escaping in YAML ("), Jinja ({) and SQL ('), plus the escape character (\).
# https://github.com/mysql/mysql-server/blob/8.0/mysys/crypt_genhash_impl.cc
MYSQL_SALT_ALPHABET = "".join(character for character in map(chr, range(33, 127)) if character not in "\"'\\{$")
# See "For SHA-256:" at https://www.akkadia.org/drepper/SHA-crypt.txt
MYSQL_ORDER = (
    (0, 10, 20),
    (21, 1, 11),
    (12, 22, 2),
    (3, 13, 23),
    (24, 4, 14),
    (15, 25, 5),
    (6, 16, 26),
    (27, 7, 17),
    (18, 28, 8),
    (9, 19, 29),
    (31, 30),
)

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
