

FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

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

    # WireGuard requirements: Temp packages (used only during Docker build)
    TEMP_PACKAGES+=(build-essential) && \
    TEMP_PACKAGES+=(pkg-config) && \

    # SkySquitter requirements: Kept packages (used in Docker at runtime)
    KEPT_PACKAGES+=(openjdk-17-jre-headless) && \

    # General packages for container debugging/maintenance: Kept packages (used in Docker at runtime)
    KEPT_PACKAGES+=(tcpdump) && \
    KEPT_PACKAGES+=(nano) && \
    KEPT_PACKAGES+=(vim) && \ # added especially for Rui :)

#
# Install all these packages:
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} && \
#
# Install WireGuard
WIREGUARD_RELEASE=$(curl -sX GET "https://api.github.com/repos/WireGuard/wireguard-tools/tags" | jq -r .[0].name) && \
mkdir -p /app && \
pushd /app && \
  git clone --depth 1 https://git.zx2c4.com/wireguard-linux-compat && \
  git clone --depth 1 https://git.zx2c4.com/wireguard-tools && \
  pushd wireguard-tools && \
    git checkout "${WIREGUARD_RELEASE}" && \
    make -C src -j$(nproc) && \
    make -C src install && \
  popd && \
popd && \

#
# Install CoreDNS
COREDNS_VERSION=$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }') && \
curl -o /tmp/coredns.tar.gz -L "https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz" && \
tar xf /tmp/coredns.tar.gz -C	/app && \

# Clean up
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
#
# Do some stuff for kx1t's convenience:
    echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
    echo "alias nano=\"nano -l\"" >> /root/.bashrc

COPY rootfs/ /

ENTRYPOINT [ "/init" ]

# Add healthcheck
# HEALTHCHECK --start-period=60s --interval=600s CMD /home/healthcheck/healthcheck.sh
