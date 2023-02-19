FROM alpine:3.16.3
LABEL maintainer="TechHypno <64381479+TechHypno@users.noreply.github.com>"
LABEL github_url="https://github.com/TechHypno/pxe"

RUN /bin/ash -c 'apk add --no-cache dnsmasq'
RUN /bin/ash -c 'apk add --no-cache nginx-mod-http-lua'

COPY config/ /etc
RUN /bin/ash -c 'chmod 666 /etc/nginx/ipxesvc/ipxe.conf'
RUN /bin/ash -c 'chmod 666 /etc/nginx/ipxesvc/lua/session.db'
# RUN /bin/ash -c 'chmod 777 /etc/nginx/ipxesvc/files'

COPY tftp/ /var/tftp
WORKDIR /var/tftp
RUN /bin/ash -c 'mkdir links'
RUN /bin/ash -c 'ln -s ../bootstrap/ipxe.efi ./links/ipxe.efi'
RUN /bin/ash -c 'ln -s ../bootstrap/ipxe.efi ./links/ipxe.efi.0'
RUN /bin/ash -c 'ln -s ../bootstrap/undionly.kpxe ./links/undionly.kpxe'
RUN /bin/ash -c 'ln -s ../bootstrap/undionly.kpxe ./links/undionly.kpxe.0'
RUN /bin/ash -c 'ln -s ../bootstrap/boot.ipxe ./links/boot.ipxe'
RUN /bin/ash -c 'ln -s ../bootstrap/boot.ipxe ./links/boot.ipxe.0'
RUN /bin/ash -c 'chown -R dnsmasq:dnsmasq *'

WORKDIR /var/log/nginx

COPY init.sh /init.sh
RUN /bin/ash -c 'chmod +x /init.sh'
ENTRYPOINT ["/init.sh"]