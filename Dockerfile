FROM debian:trixie-slim

# Set default PBS version, can be overridden at build time
ARG PBS_VERSION=4.1.2-1

RUN apt-get update && apt-get -yq --no-install-recommends install ca-certificates wget tzdata runit
RUN wget https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -O /etc/apt/trusted.gpg.d/proxmox-release.gpg
RUN printf '8678f2327c49276615288d7ca11e7d296bc8a2b96946fe565a9c81e533f9b15a5dbbad210a0ad5cd46d361ff1d3c4bac55844bc296beefa4f88b86e44e69fa51  /etc/apt/trusted.gpg.d/proxmox-release.gpg' > /checksum && sha512sum -c /checksum
COPY <<"EOT" /etc/apt/sources.list.d/pbs.sources
Types: deb
URIs: http://download.proxmox.com/debian/pbs
Suites: trixie
Components: pbs-no-subscription
Signed-By: /etc/apt/trusted.gpg.d/proxmox-release.gpg
EOT
RUN apt-get update && apt-get -yq install --no-install-recommends proxmox-backup-server=${PBS_VERSION} proxmox-archive-keyring && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
RUN rm -f /etc/apt/sources.list.d/pbs-enterprise.sources

ADD runit/ /runit/
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME /etc/proxmox-backup
VOLUME /var/log/proxmox-backup
VOLUME /var/lib/proxmox-backup

EXPOSE 8007

ENTRYPOINT ["/docker-entrypoint.sh"]
HEALTHCHECK --interval=15s --timeout=10s --retries=3 --start-period=30s CMD curl -kf http://localhost:8007/ || exit 1
