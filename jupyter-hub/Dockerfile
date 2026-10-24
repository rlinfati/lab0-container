FROM registry.access.redhat.com/ubi10/ubi-minimal

USER root
WORKDIR /tmp/

RUN microdnf --assumeyes install shadow-utils && \
    microdnf clean all

ENV PATH=$PATH:/opt/conda/bin/
ARG CONDA_PLUGINS_AUTO_ACCEPT_TOS=true

RUN curl --fail --remote-name https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh && \
    bash Miniconda3-latest-Linux-$(uname -m).sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-$(uname -m).sh && \
    conda clean --all --yes && \
    conda info

RUN conda install --quiet --yes jupyterhub && \
    conda install --quiet --yes oauthenticator && \
    conda install --quiet --yes python-kubernetes && \
    conda install --quiet --yes jupyterhub-kubespawner && \
    conda install --quiet --yes jupyterhub-idle-culler && \
    conda clean --all --yes && \
    jupyterhub --version

RUN useradd --uid 1000 --gid 100 --create-home --no-user-group jhub

USER jhub
WORKDIR /home/jhub/

EXPOSE 8000/tcp
ENTRYPOINT ["jupyterhub"]
CMD ["--JupyterHub.config_file=/etc/jupyterhub/jupyterhub_config.py"]
