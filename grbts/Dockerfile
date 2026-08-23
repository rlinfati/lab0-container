################
# Stage stage1 #
################

FROM registry.access.redhat.com/ubi10/ubi-minimal AS stage1

ARG GRBVERX=13.0
ARG GRBFILE=gurobi13.0.0_linux64.tar.gz
# FIX: GRBVERX=13.0
# FIX: GRBFILE=gurobi13.0.0_linux64.tar.gz

USER root
WORKDIR /tmp/

RUN microdnf --assumeyes install tar gzip && \
    microdnf clean all

RUN curl -O https://packages.gurobi.com/${GRBVERX}/${GRBFILE} && \
    tar xf ${GRBFILE} -C /opt && \
    cp /opt/gurobi*/*/bin/{grb_ts,grbgetkey,grbprobe} /usr/local/bin && \
    ls -la /opt/gurobi*/*/bin/ && \
    ls -la /opt/gurobi*/*/lib/ && \
    ls -la /usr/local/bin

###############
# Stage FINAL #
###############

FROM registry.access.redhat.com/ubi10/ubi-micro

USER root
WORKDIR /tmp/
EXPOSE 41954/tcp
VOLUME /opt/gurobi

COPY --from=stage1 /usr/local/bin/grb_ts            /usr/local/bin/grb_ts
COPY --from=stage1 /usr/local/bin/grbgetkey         /usr/local/bin/grbgetkey
COPY --from=stage1 /usr/local/bin/grbprobe          /usr/local/bin/grbprobe
COPY --from=stage1 /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt

CMD grbprobe && cat /opt/gurobi/gurobi.lic && grb_ts -v -n || tail -f /dev/null
