###############
# Stage build #
###############

FROM registry.access.redhat.com/ubi10/ubi-minimal AS builder

USER root
WORKDIR /tmp/

RUN microdnf --assumeyes install git-core make gcc && \
    microdnf clean all

RUN git clone https://github.com/Wind4/vlmcsd.git --depth 1 && \
    cd vlmcsd && \
    make vlmcsd

# RUN dnf --assumeyes install git-core unzip make gcc && dnf clean all
# COPY vlmcsd-master.zip /tmp/
# RUN unzip vlmcsd-master.zip && cd vlmcsd-master && make vlmcsd

###############
# Stage FINAL #
###############

FROM registry.access.redhat.com/ubi10/ubi-micro

USER root
WORKDIR /tmp/
EXPOSE 1688/tcp

COPY --from=builder /tmp/vlmcsd/bin/vlmcsd /usr/local/bin/vlmcsd

ENTRYPOINT ["vlmcsd"]
CMD ["-D", "-e", "-v"]
