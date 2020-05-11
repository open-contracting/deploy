#!/usr/bin/env python
import subprocess
from collections import defaultdict

import click


def get_provider(target):
    if 'kingfisher' in target:
        return 'hetzner'
    else:
        return 'bytemark'


def compare(content, get_item):
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
            if count == provider_count[provider]:
                provider_items[provider].add(item)

    for target in sorted(target_items):
        print('{}:'.format(target))
        for item in target_items[target]:
            provider = get_provider(target)
            if item not in provider_items[provider]:
                print('  {}'.format(item))


@click.group()
def cli():
    pass


@click.command()
def services():
    """
    List services that are not common to all servers of the same provider.
    """
    content = subprocess.run(['salt-ssh', '*', 'service.get_all'], check=True, stdout=subprocess.PIPE).stdout.decode()
    compare(content, lambda line: line.strip()[2:])


@click.command()
def packages():
    """
    List packages that are not common to all servers of the same provider.
    """
    content = subprocess.run(['salt-ssh', '*', 'pkg.list_pkgs'], check=True, stdout=subprocess.PIPE).stdout.decode()
    compare(content, lambda line: line.strip()[:-1])


cli.add_command(services)
cli.add_command(packages)

if __name__ == '__main__':
    cli()
