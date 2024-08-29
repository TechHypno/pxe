#!/bin/ash
cp -r -n /userdata_defaults/* /userdata
chmod 664 /userdata/ipxe.conf
chmod 664 /userdata/session.db
chmod 774 /userdata/files
chown -Rh nginx:www-data /userdata
dnsmasq --dhcp-range=$PXE_SERVERIP,proxy --dhcp-option=option:router,$PXE_ROUTERIP
nginx