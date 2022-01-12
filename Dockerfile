

FROM debian:buster-20211220-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy needs to be here to prevent github actions from failing.
# SSL Certs are pre-loaded into the rootfs via a job in github action:
# See: "Copy CA Certificates from GitHub Runner to Image rootfs" in deploy.yml
COPY root_certs/ /

RUN set -x && \
# define packages needed for installation and general management of the container:
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    TEMP_PACKAGES+=(gnupg2) && \
    TEMP_PACKAGES+=(file) && \
    KEPT_PACKAGES+=(curl) && \
    KEPT_PACKAGES+=(ca-certificates) && \
    KEPT_PACKAGES+=(procps) && \
    KEPT_PACKAGES+=(nano) && \
    KEPT_PACKAGES+=(socat) && \
    KEPT_PACKAGES+=(netcat) && \
    KEPT_PACKAGES+=(psmisc) && \
    KEPT_PACKAGES+=(net-tools) && \
    TEMP_PACKAGES+=(git) && \
#
# Install all these packages:
    apt-get update && \
    apt-get install --force-yes -y \
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} && \

#
# Install @Mikenye's HealthCheck framework (https://github.com/mikenye/docker-healthchecks-framework)
    mkdir -p /opt && \
    git clone \
          --depth=1 \
          https://github.com/mikenye/docker-healthchecks-framework.git \
          /opt/healthchecks-framework \
          && \
    rm -rf \
      /opt/healthchecks-framework/.git* \
      /opt/healthchecks-framework/*.md \
      /opt/healthchecks-framework/tests \
      && \
#
#
# install S6 Overlay
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
#
# Clean up
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
#
# Do some stuff for kx1t's convenience:
    echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
    echo "alias nano=\"nano -l\"" >> /root/.bashrc

COPY rootfs/ /

RUN set -x && \

ENTRYPOINT [ "/init" ]

# Add healthcheck
# HEALTHCHECK --start-period=60s --interval=600s CMD /home/healthcheck/healthcheck.sh
