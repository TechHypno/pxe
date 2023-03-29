#!/bin/ash
cp -r -n /userdata_defaults/* /userdata
chmod 664 /userdata/ipxe.conf
chmod 664 /userdata/session.db
chmod 774 /userdata/files
chown -R nginx:nginx /userdata/*
dnsmasq --dhcp-range=$PXE_SERVERIP,proxy --dhcp-option=option:router,$PXE_ROUTERIP
nginx