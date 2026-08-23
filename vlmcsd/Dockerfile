################
# Stage stage1 #
################

FROM registry.access.redhat.com/ubi10/ubi AS stage1

USER root
WORKDIR /tmp/

RUN dnf --assumeyes install git-core make gcc && \
    dnf clean all

RUN git clone https://github.com/Wind4/vlmcsd.git --depth 1 && \
    cd vlmcsd && \
    make vlmcsd

################
# Stage stage2 #
################

FROM registry.access.redhat.com/ubi10/ubi AS stage2

USER root
WORKDIR /tmp/

RUN dnf --assumeyes install unzip make gcc && \
    dnf clean all

COPY vlmcsd-master.zip /tmp/
RUN unzip vlmcsd-master.zip && \
    cd vlmcsd-master && \
    make vlmcsd

###############
# Stage FINAL #
###############

FROM registry.access.redhat.com/ubi10/ubi-micro

USER root
WORKDIR /tmp/
EXPOSE 1688/tcp

COPY --from=stage2 /tmp/vlmcsd-master/bin/vlmcsd /usr/local/bin/vlmcsd
COPY --from=stage1 /tmp/vlmcsd/bin/vlmcsd /usr/local/bin/vlmcsd

CMD /usr/local/bin/vlmcsd -Dev
