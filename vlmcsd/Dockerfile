################
# Stage stage1 #
################

FROM registry.access.redhat.com/ubi10/ubi AS stage1

USER root
WORKDIR /tmp/

RUN dnf --assumeyes install unzip make gcc && \
    dnf clean all

# git clone https://github.com/Wind4/vlmcsd.git --depth 1 
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

COPY --from=stage1 /tmp/vlmcsd-master/bin/vlmcsd /usr/local/bin/vlmcsd

ENTRYPOINT ["/usr/local/bin/vlmcsd"]
CMD ["-D", "-e", "-v"]
