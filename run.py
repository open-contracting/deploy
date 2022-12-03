#!/usr/bin/env python
import builtins
import os
import socket
import sys

# https://github.com/saltstack/salt/issues/62664#issuecomment-1336017055
os.environ["HOMEBREW_PREFIX"] = "/opt/homebrew"

import salt.cli.ssh
import salt.roster


def main():
    # Replace program name to match Saltfile.
    sys.argv[0] = "salt-ssh"

    # See salt/scripts.py::salt_ssh
    client = salt.cli.ssh.SaltSSH()

    # See salt/cli/ssh.py::SaltSSH
    client.parse_args()

    # See salt/client/ssh/__init__.py::SSH
    # Allows using the `-L` flag as documented in the docs/maintain/packages.rst file.
    tgt_type = client.config["selected_target_option"] if client.config["selected_target_option"] else "glob"
    roster = salt.roster.Roster(client.config, client.config.get("roster", "flat"))
    targets = roster.targets(client.config["tgt"], tgt_type)

    # Port-knock all the targets.
    print("Port-knocking:")
    for name, target in targets.items():
        print(f"- {target['host']} ({name})")
    for target in targets.values():
        try:
            socket.create_connection((target["host"], 8255), 1)
        except OSError:
            pass

    # Run salt-ssh as usual.
    print("Running...")
    os.execvp("salt-ssh", sys.argv)


if __name__ == "__main__":
    main()
