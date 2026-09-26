FROM quay.io/fedora/fedora:44
# FIX: fedora:44

USER root
WORKDIR /tmp/
EXPOSE  500/udp
EXPOSE 4500/udp

RUN dnf install --assumeyes strongswan nftables && \
    dnf clean all
