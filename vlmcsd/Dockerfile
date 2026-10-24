#################
# Stage builder #
#################

FROM registry.access.redhat.com/ubi10/ubi AS builder

USER root
WORKDIR /tmp/

RUN dnf --assumeyes install git-core make gcc && \
    dnf clean all

RUN git clone https://github.com/Wind4/vlmcsd.git --depth 1 && \
    cd vlmcsd && \
    make vlmcsd

###############
# Stage FINAL #
###############

FROM registry.access.redhat.com/ubi10/ubi-micro

USER root
WORKDIR /tmp/
EXPOSE 1688/tcp

COPY --from=builder /tmp/vlmcsd/bin/vlmcsd /usr/local/bin/vlmcsd

USER nobody

ENTRYPOINT ["/usr/local/bin/vlmcsd"]
CMD ["-D", "-e", "-v"]
