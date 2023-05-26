#!/bin/sh
# https://superuser.com/a/1622435/1803567
"""$(dirname $(which salt-ssh))"/bin/python3 - "$@" <<"EOF"""

import os
import socket
import sys

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
        try:
            socket.create_connection((target["host"], 8255), 1)
        except OSError:
            pass

    # Run salt-ssh as usual.
    print("Running...")
    os.execvp("salt-ssh", sys.argv)


if __name__ == "__main__":
    main()
