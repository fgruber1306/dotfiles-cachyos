# Proton VPN (WireGuard via NetworkManager)
Configs are NOT in this repo (they contain private keys!).
Keep them in your password manager / encrypted on the NAS.

    nmcli connection import type wireguard file proton-at.conf
    nmcli connection modify proton-at connection.autoconnect yes
    nmcli connection up proton-at
    curl ifconfig.me   # should print a Proton IP
