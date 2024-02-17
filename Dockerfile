FROM debian:bookworm-slim

RUN apt-get update && apt-get -yq install wget tzdata runit
RUN wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
RUN printf '7da6fe34168adc6e479327ba517796d4702fa2f8b4f0a9833f5ea6e6b48f6507a6da403a274fe201595edc86a84463d50383d07f64bdde2e3658108db7d6dc87  /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg' > /checksum && sha512sum -c /checksum
RUN printf 'deb http://download.proxmox.com/debian/pbs bookworm pbs-no-subscription' > /etc/apt/sources.list.d/pbs.list
RUN apt-get update && apt-get -yq install --no-install-recommends proxmox-backup-server proxmox-archive-keyring && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ADD runit/ /runit/

VOLUME /etc/proxmox-backup
VOLUME /var/log/proxmox-backup
VOLUME /var/lib/proxmox-backup

EXPOSE 8007

CMD ["runsvdir", "/runit"]

HEALTHCHECK --interval=15s --timeout=10s --retries=3 --start-period=30s CMD curl -kf http://localhost:8007/ || exit 1
