FROM quay.io/fedora/fedora:latest

USER root
WORKDIR /tmp/
EXPOSE  500/udp
EXPOSE 4500/udp

RUN dnf install --assumeyes strongswan nftables && \
    dnf clean all
