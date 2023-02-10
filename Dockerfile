FROM alpine:3.16.3
LABEL maintainer="TechHypno <64381479+TechHypno@users.noreply.github.com>"
LABEL github_url="https://github.com/TechHypno/pxe"

RUN apk add --no-cache dnsmasq
RUN apk add --no-cache nginx-mod-http-lua

COPY config/ /etc
RUN chmod a=rw /etc/nginx/ipxesvc/ipxe.conf
RUN chmod a=rw /etc/nginx/ipxesvc/lua/session.db

COPY tftp/ /var/tftp
WORKDIR /var/tftp
RUN mkdir links
RUN ln -sf bootstrap/ipxe.efi links/ipxe.efi
RUN ln -sf bootstrap/ipxe.efi links/ipxe.efi.0
RUN ln -sf bootstrap/undionly.kpxe links/undionly.kpxe
RUN ln -sf bootstrap/undionly.kpxe links/undionly.kpxe.0
RUN ln -sf bootstrap/boot.ipxe links/boot.ipxe
RUN ln -sf bootstrap/boot.ipxe links/boot.ipxe.0

WORKDIR /var/log/nginx

COPY init.sh /init.sh
RUN chmod a=x /init.sh
ENTRYPOINT ["/init.sh"]