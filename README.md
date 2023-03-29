# **A simple pxe service container.**

## Environment variables:
- `PXE_SERVERIP` - lan ip pointing at this service. (`default: 192.168.1.10`)
- `PXE_ROUTERIP` - lan ip pointing at the DHCP server. (`default: 192.168.1.1`)
- `PXE_PASSWORD` - a password for the web interface. (`default: password`)
- `PXE_DATAPATH` - host file path for storing config files (`default: ./pxe`).

For portainer change `PXE_DATAPATH` to `/portainer/Files/AppData/Config/pxe` .

## Web interface login on port 8067
![login page](assets/login.png?raw=true "Login")

## Main iPXE script editor
![ipxe script editor](assets/main.png?raw=true "iPXE")

`#!ipxe` followed by match criteria begins a script block.

Multiple script blocks can be included.
First match is returned to an iPXE request.

Criteria priority for a successful match:
1. uuid + address
2. uuid
3. address

## Additional text files can be created to be referenced in the main script.
![additional config files](assets/files.png?raw=true "Configs")