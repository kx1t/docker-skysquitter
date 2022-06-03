

#FROM linuxserver/wireguard:latest
FROM ghcr.io/sdr-enthusiasts/docker-baseimage:python

# Preset a number of ENV variables as fall back when not defined at runtime:
ENV START_DELAY=0
ENV LOGGING=false
ENV RECV_HOST=readsb
ENV RECV_PORT=30005
ENV RECV_TIMEOUT=60
ENV DEST_HOST=10.9.2.1
ENV DEST_PORT=11092

# hadolint ignore=SC2115
RUN set -x && \
#
# Install these packages:
  TEMP_PACKAGES=() && \
  KEPT_PACKAGES=() && \
  KEPT_PACKAGES+=(netcat) && \
  KEPT_PACKAGES+=(tcpdump) && \
  KEPT_PACKAGES+=(nano) && \
  KEPT_PACKAGES+=(vim) && \
  KEPT_PACKAGES+=(iputils-ping) && \
  KEPT_PACKAGES+=(openjdk-17-jre-headless) && \
  KEPT_PACKAGES+=(iproute2) && \
  KEPT_PACKAGES+=(openresolv) && \
  KEPT_PACKAGES+=(wireguard-dkms) && \
  KEPT_PACKAGES+=(wireguard-tools) && \
#
  apt-get update && \
  echo "The following dependencies will also be installed:" && \
  apt-cache depends "${KEPT_PACKAGES[@]}" "${TEMP_PACKAGES[@]}" && \
  echo "----------------------------------------" && \
  apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" -y --no-install-recommends  --no-install-suggests \
    "${KEPT_PACKAGES[@]}" "${TEMP_PACKAGES[@]}" && \

# Clean up
   if [[ -n "${#TEMP_PACKAGES[@]}" ]]; then apt-get remove -y "${TEMP_PACKAGES[@]}"; fi && \
   apt-get autoremove -y && \
   apt-get clean -y && \
   rm -rf /src /tmp/* /var/lib/apt/lists/* /boot/* /vmlinuz* /initrd.img* && \
#
# Do some stuff for kx1t's convenience:
  echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
  echo "alias nano=\"nano -l\"" >> /root/.bashrc

COPY rootfs/ /

# Add healthcheck
# HEALTHCHECK --start-period=60s --interval=600s CMD /home/healthcheck/healthcheck.sh
