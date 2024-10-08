FROM alpine:3.16.3
LABEL maintainer="TechHypno <64381479+TechHypno@users.noreply.github.com>"
LABEL github_url="https://github.com/TechHypno/pxe"

RUN apk add --no-cache dnsmasq
RUN apk add --no-cache nginx-mod-http-lua

COPY etc/. /etc/
RUN chown -R nginx:www-data /etc/nginx
RUN chmod -R 755 /etc/nginx

COPY userdata/. /userdata_defaults/
RUN mkdir /userdata_defaults/files

COPY --chown=dnsmasq:dnsmasq --chmod=664 tftp/. /var/tftp/
WORKDIR /var/tftp
RUN mkdir links
RUN ln -s ../bootstrap/ipxe.efi ./links/ipxe.efi
RUN ln -s ../bootstrap/ipxe.efi ./links/ipxe.efi.0
RUN ln -s ../bootstrap/undionly.kpxe ./links/undionly.kpxe
RUN ln -s ../bootstrap/undionly.kpxe ./links/undionly.kpxe.0
RUN ln -s ../bootstrap/boot.ipxe ./links/boot.ipxe
RUN ln -s ../bootstrap/boot.ipxe ./links/boot.ipxe.0
RUN chown -R dnsmasq:dnsmasq *
RUN chmod -R 664 *


WORKDIR /var/log/nginx

COPY init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]