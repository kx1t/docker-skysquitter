

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

RUN set -x && \
#
# Install these packages:
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless \
        netcat \
        tcpdump \
        nano \
        vim \
        iputils-ping \
        openjdk-17-jre-headless \
        iproute2 \
        openresolv \
        wireguard && \

#    echo ${TEMP_PACKAGES[@]} > /tmp/temp_packages
#
#
# Now add a layer with the local builds
# Note -- there are no local build requirements so this layer isnt necessary
#RUN set -x && \
#    TEMP_PACKAGES=$(cat /tmp/temp_packages) && \
#    apt-get update && \
#    apt-get install -y --no-install-recommends ${TEMP_PACKAGES[@]} && \
#
# Clean up
#    apt-get remove -y ${TEMP_PACKAGES[@]} && \
     apt-get autoremove -y && \
     apt-get clean -y && \
     rm -rf /src /tmp/* /var/lib/apt/lists/* /boot/* /vmlinuz* && \
#
# Do some stuff for kx1t's convenience:
    echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
    echo "alias nano=\"nano -l\"" >> /root/.bashrc

COPY rootfs/ /

# Add healthcheck
# HEALTHCHECK --start-period=60s --interval=600s CMD /home/healthcheck/healthcheck.sh
