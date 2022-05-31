

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

    # WireGuard requirements: Temp packages (used only during Docker build)
    TEMP_PACKAGES+=(build-essential) && \
    TEMP_PACKAGES+=(pkg-config) && \
    TEMP_PACKAGES+=(git) && \

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

    echo ${TEMP_PACKAGES[@]} > /tmp/temp_packages

#
# Now add a layer with the local builds
RUN set -x && \
    TEMP_PACKAGES=$(cat /tmp/packages) &&
    apt-get update && \
    apt-get install -y --no-install-recommends ${TEMP_PACKAGES[@]} && \
#
# Figure out the environment. This will be needed later to install CoreDNS
ARCH_NAME="$(uname -m)" && ARCH_NAME="${ARCH_NAME,,}" && \
if [[ "${ARCH_NAME:0:6}" == "x86_64" ]]; then ARCH_NAME="amd64"; fi && \
if [[ "${ARCH_NAME:0:3}" == "arm" ]]; then ARCH_NAME="arm"; fi && \
if [[ "${ARCH_NAME:0:7}" == "aarch64" ]]; then ARCH_NAME="arm64"; fi && \
OS_NAME="$(uname -s)" && OS_NAME="${OS_NAME,,}" && \
#
# Install WireGuard
WIREGUARD_RELEASE=$(curl -sX GET "https://api.github.com/repos/WireGuard/wireguard-tools/tags" | jq -r .[0].name) && \
mkdir -p /app && \
pushd /app && \
  git clone https://git.zx2c4.com/wireguard-linux-compat && \
  git clone https://git.zx2c4.com/wireguard-tools && \
  pushd wireguard-tools && \
    git checkout "${WIREGUARD_RELEASE}" && \
    make -C src -j$(nproc) && \
    make -C src install && \
  popd && \
popd && \
#
# Install CoreDNS
COREDNS_VERSION="$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }' )" && \
curl -o /tmp/coredns.tar.gz -L "https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_${OS_NAME}_${ARCH_NAME}.tgz" && \
tar xf /tmp/coredns.tar.gz -C /app && \
#
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
