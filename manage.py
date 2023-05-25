#!/usr/bin/env python
import os
import socket
import subprocess
import sys
from collections import defaultdict

# https://github.com/saltstack/salt/issues/62664#issuecomment-1336017055
os.environ["HOMEBREW_PREFIX"] = "/opt/homebrew"

import click
import salt.cli.ssh
import salt.client.ssh

PROVIDERS = (
    'linode',
    'hetzner',
)


def get_provider(target):
    if 'kingfisher' in target or 'registry' in target:
        return 'hetzner'
    else:
        return 'linode'


def compare(content, get_item, mode='diff', margin=0, providers=None):
    provider_count = defaultdict(int)
    target_items = defaultdict(list)
    item_providers = defaultdict(lambda: defaultdict(int))

    target = None
    provider = None
    for line in content.splitlines():
        if line.startswith('        '):
            continue
        elif line.startswith(' '):
            item = get_item(line.strip())
            target_items[target].append(item)
            item_providers[item][provider] += 1
        else:
            target = line[:-1]
            provider = get_provider(target)
            provider_count[provider] += 1

    provider_items = defaultdict(set)
    for item, providers in item_providers.items():
        for provider, count in providers.items():
            if count >= provider_count[provider] - margin:
                provider_items[provider].add(item)

    for target in sorted(target_items):
        provider = get_provider(target)
        if provider not in providers:
            continue
        print(f'{target}:')
        for item in target_items[target]:
            included = item in provider_items[provider]
            if mode == 'diff' and not included or mode == 'comm' and included:
                print(f'  {item}')


def salt_ssh(*args):
    # See run.py
    sys.argv = ['salt-ssh', *args]
    client = salt.cli.ssh.SaltSSH()
    client.parse_args()
    ssh = salt.client.ssh.SSH(client.config)

    for target in ssh.targets.values():
        try:
            socket.create_connection((target['host'], 8255), 1)
        except OSError:
            pass

    return subprocess.run(sys.argv, check=True, stdout=subprocess.PIPE).stdout.decode()


@click.group()
def cli():
    pass

@cli.command()
@click.argument('destination')
def connect(destination):
    """
    Port-knock then connect to a destination using SSH.
    """
    user, host = destination.split('@')
    try:
        socket.create_connection((host, 8255), 1)
    except socket.timeout:
        pass
    except ConnectionRefusedError:
        print('port 8255 closed')
    os.execvp('ssh', ('ssh', destination))


@cli.command()
@click.option('--provider', type=click.Choice(PROVIDERS), default=PROVIDERS, multiple=True,
              help='the providers to report on')
def services(provider):
    """
    List services that are not common to all servers of the same provider.
    """
    content = salt_ssh('*', 'service.get_all')
    compare(content, lambda line: line.strip()[2:], providers=provider)


@cli.command()
@click.option('--provider', type=click.Choice(PROVIDERS), default=PROVIDERS, multiple=True,
              help='the providers to report on')
def packages(provider):
    """
    List packages that are not common to all servers of the same provider.
    """
    content = salt_ssh('*', 'pkg.list_pkgs')
    compare(content, lambda line: line.strip()[:-1], providers=provider)


@cli.command()
@click.option('--margin', type=int, default=0,
              help='the margin within which packages are considered to be common to all servers')
@click.option('--provider', type=click.Choice(PROVIDERS), default=PROVIDERS, multiple=True,
              help='the providers to report on')
def autoremove(margin, provider):
    """
    List packages that can be auto-removed and that are common to all servers of the same provider.
    """
    content = salt_ssh('*', 'pkg.autoremove', 'list_only=True')
    compare(content, lambda line: line.strip()[2:], mode='comm', margin=margin, providers=provider)


if __name__ == '__main__':
    cli()
