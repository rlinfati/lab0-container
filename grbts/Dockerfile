#################
# Stage builder #
#################

FROM registry.access.redhat.com/ubi10/ubi-minimal AS builder

# renovate: datasource=conda depName=gurobi/gurobi extractVersion=^(?<version>\d+\.\d+)(?:\.\d+)?$
ARG GRBVER=13.0
ARG GRBARCH=linux64

USER root
WORKDIR /tmp/

RUN microdnf --assumeyes install tar gzip && \
    microdnf clean all

RUN curl --fail --remote-name https://packages.gurobi.com/${GRBVER}/gurobi${GRBVER}.0_${GRBARCH}.tar.gz && \
    tar xf gurobi${GRBVER}.0_${GRBARCH}.tar.gz -C /opt && \
    for bin in grb_ts grbgetkey grbprobe; do cp /opt/gurobi*/*/bin/${bin} /usr/local/bin/; done

###############
# Stage FINAL #
###############

FROM registry.access.redhat.com/ubi10/ubi-micro

USER root
WORKDIR /tmp/
EXPOSE 41954/tcp
VOLUME /opt/gurobi

COPY --from=builder /usr/local/bin/grb_ts            /usr/local/bin/grb_ts
COPY --from=builder /usr/local/bin/grbgetkey         /usr/local/bin/grbgetkey
COPY --from=builder /usr/local/bin/grbprobe          /usr/local/bin/grbprobe
COPY --from=builder /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt

USER nobody

ENTRYPOINT ["/usr/local/bin/grb_ts"]
CMD ["-v", "-n"]
