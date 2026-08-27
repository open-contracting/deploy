#!/bin/sh
# https://superuser.com/a/1622435/1803567
"""$(dirname $(readlink $(which salt-ssh) || which salt-ssh))"/bin/python3 - "$@" <<"EOF"""

import contextlib
import os
import shutil
import socket
import sys
from pathlib import Path

# Otherwise, Salt determines the prefix by running `brew` via `su`, which fails without a password.
if "HOMEBREW_PREFIX" not in os.environ and (brew := shutil.which("brew")):
    os.environ["HOMEBREW_PREFIX"] = str(Path(brew).parents[1])

import salt.cli.ssh
import salt.client.ssh


def main():
    # Replace program name to match Saltfile.
    sys.argv[0] = "salt-ssh"

    # See salt/scripts.py::salt_ssh
    client = salt.cli.ssh.SaltSSH()

    # See salt/cli/ssh.py::SaltSSH
    client.parse_args()
    ssh = salt.client.ssh.SSH(client.config)

    # Port-knock all the targets.
    print("Port-knocking:")
    for name, target in ssh.targets.items():
        print(f"- {target['host']} ({name})")
    for target in ssh.targets.values():
        with contextlib.suppress(OSError):
            socket.create_connection((target["host"], 8255), 1)

    # Run salt-ssh as usual.
    print("Running...")
    os.execvp("salt-ssh", sys.argv)  # noqa: S606,S607


if __name__ == "__main__":
    main()
