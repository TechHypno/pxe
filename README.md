# **A simple pxe service container.**

## environment variables:
- `PXE_SERVERIP` - lan ip pointing at this service. (`default: 192.168.1.10`)
- `PXE_ROUTERIP` - lan ip pointing at the DHCP server. (`default: 192.168.1.1`)
- `PXE_PASSWORD` - a password for the web interface. (`default: password`)
- `PXE_DATAPATH` - host file path for storing config files (`default: ./pxe`)