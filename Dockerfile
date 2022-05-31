

FROM ghcr.io/sdr-enthusiasts/docker-baseimage:python

# Preset a number of ENV variables as fall back when not defined at runtime:
ENV START_DELAY=5000
ENV LOGGING=false
ENV RECV_HOST=localhost
ENV RECV_PORT=30005
ENV RECV_TIMEOUT=60
ENV DEST_HOST=10.9.2.1
ENV DEST_PORT=11092


RUN set -x && \
# define packages needed for installation and general management of the container:
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \

    # WireGuard requirements: Kept packages (used in Docker at runtime)
    KEPT_PACKAGES+=(dkms) && \
    KEPT_PACKAGES+=(gnupg) && \
    KEPT_PACKAGES+=(ifupdown) && \
    KEPT_PACKAGES+=(iputils-ping) && \
    KEPT_PACKAGES+=(jq) && \
    KEPT_PACKAGES+=(libc6) && \
    KEPT_PACKAGES+=(libelf-dev) && \
    KEPT_PACKAGES+=(openresolv) && \
    KEPT_PACKAGES+=(perl) && \
    KEPT_PACKAGES+=(qrencode) && \
    KEPT_PACKAGES+=(wireguard) && \
    KEPT_PACKAGES+=(wireguard-tools) && \

    # SkySquitter requirements: Kept packages (used in Docker at runtime)
    KEPT_PACKAGES+=(openjdk-17-jre-headless) && \

    # General packages for container debugging/maintenance: Kept packages (used in Docker at runtime)
    KEPT_PACKAGES+=(tcpdump) && \
    KEPT_PACKAGES+=(nano) && \
    KEPT_PACKAGES+=(vim) && \
#
# Install all these packages:
    apt-get update && \
    apt-get install -y --no-install-recommends ${KEPT_PACKAGES[@]} && \

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
#    apt-get autoremove -y && \
#    apt-get clean -y && \
#    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
#
# Do some stuff for kx1t's convenience:
    echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
    echo "alias nano=\"nano -l\"" >> /root/.bashrc

COPY rootfs/ /

ENTRYPOINT [ "/init" ]

# Add healthcheck
# HEALTHCHECK --start-period=60s --interval=600s CMD /home/healthcheck/healthcheck.sh
