

#FROM linuxserver/wireguard:latest
FROM ghcr.io/sdr-enthusiasts/docker-baseimage:python

# Preset a number of ENV variables as fall back when not defined at runtime:
ENV RECV_HOST=readsb
ENV RECV_PORT=30005
ENV DEST_HOST=10.9.2.1
ENV DEST_PORT=11092
ENV FAILURE_TIMEOUT=150
ENV PRUNE_INTERVAL=12h
ENV PRUNE_SIZE=1000
ENV CLOCK_DIFF_LIMIT=200
ENV MAXDRIFT=400

# hadolint ignore=SC2115,SC3054
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
  KEPT_PACKAGES+=(iputils-clockdiff) && \
# KEPT_PACKAGES+=(openjdk-17-jre-headless) && \
  KEPT_PACKAGES+=(iproute2) && \
  KEPT_PACKAGES+=(openresolv) && \
  KEPT_PACKAGES+=(wireguard-dkms) && \
  KEPT_PACKAGES+=(wireguard-tools) && \
  TEMP_PACKAGES+=(git) && \
#
  apt-get update && \
  echo "The following dependencies will also be installed:" && \
  apt-cache depends "${KEPT_PACKAGES[@]}" "${TEMP_PACKAGES[@]}" && \
  echo "----------------------------------------" && \
  apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" -y --no-install-recommends  --no-install-suggests \
    "${KEPT_PACKAGES[@]}" "${TEMP_PACKAGES[@]}" && \
#
# Install the Python feeder
   mkdir /git && \
   git clone --depth 1 https://github.com/skysquitter22/beast-feeder /git && \
   cp /git/beast-feeder.py /usr/local/bin/beast-feeder && \
   cp /git/.VERSION.beast-feeder / || : && \
   chmod a+x /usr/local/bin/beast-feeder && \
#
# Clean up
   if [[ -n "${#TEMP_PACKAGES[@]}" ]]; then apt-get remove -y "${TEMP_PACKAGES[@]}"; fi && \
   apt-get autoremove -y && \
   apt-get clean -y && \
   rm -rf /src /tmp/* /var/lib/apt/lists/* /git && \
#
# Do some stuff for kx1t's convenience:
  echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
  echo "alias nano=\"nano -l\"" >> /root/.bashrc

COPY rootfs/ /

# Add healthcheck
# HEALTHCHECK --start-period=60s --interval=600s CMD /home/healthcheck/healthcheck.sh
