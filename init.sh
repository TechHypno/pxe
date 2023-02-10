#!/bin/sh

dnsmasq --dhcp-range=$PXE_SERVERIP,proxy --dhcp-option=option:router,$PXE_ROUTERIP
nginx