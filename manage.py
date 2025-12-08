#!/usr/bin/env python3
import re
from email.parser import Parser
from email.policy import default

import click


@click.group()
def cli():
    pass


@cli.command()
@click.argument("file", type=click.File())
def print_urls_from_email_message(file):
    message = Parser(policy=default).parsestr(file.read())
    print("\n".join(re.findall(r"http[^\s>]+", message.get_body(preferencelist=("plain", "html")).get_content())))


if __name__ == "__main__":
    cli()
