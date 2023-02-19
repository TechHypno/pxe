FROM alpine:3.16.3
LABEL maintainer="TechHypno <64381479+TechHypno@users.noreply.github.com>"
LABEL github_url="https://github.com/TechHypno/pxe"

RUN apk add --no-cache dnsmasq
RUN apk add --no-cache nginx-mod-http-lua

COPY config/ /etc
RUN chmod 666 /etc/nginx/ipxesvc/ipxe.conf
RUN chmod 666 /etc/nginx/ipxesvc/lua/session.db
RUN mkdir /etc/nginx/ipxesvc/files
RUN chmod 777 /etc/nginx/ipxesvc/files

COPY tftp/ /var/tftp
WORKDIR /var/tftp
RUN mkdir links
RUN ln -s ../bootstrap/ipxe.efi ./links/ipxe.efi
RUN ln -s ../bootstrap/ipxe.efi ./links/ipxe.efi.0
RUN ln -s ../bootstrap/undionly.kpxe ./links/undionly.kpxe
RUN ln -s ../bootstrap/undionly.kpxe ./links/undionly.kpxe.0
RUN ln -s ../bootstrap/boot.ipxe ./links/boot.ipxe
RUN ln -s ../bootstrap/boot.ipxe ./links/boot.ipxe.0
RUN chown -R dnsmasq:dnsmasq *

WORKDIR /var/log/nginx

COPY init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]