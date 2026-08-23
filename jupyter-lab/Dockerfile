ARG TARGET=julia

##############
# Stage base #
##############

FROM registry.access.redhat.com/ubi10/ubi-minimal AS base

USER root
WORKDIR /tmp/

ENV PATH=$PATH:/opt/conda/bin/
ARG CONDA_PLUGINS_AUTO_ACCEPT_TOS=true

RUN microdnf --assumeyes install git-core && \
    microdnf --assumeyes install unzip zip tar gzip && \
    microdnf --assumeyes install findutils dos2unix && \
    microdnf --assumeyes install procps-ng && \
    microdnf clean all

RUN curl --remote-name https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh && \
    bash Miniconda3-latest-Linux-$(uname -m).sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-$(uname -m).sh && \
    conda clean --all --yes && \
    conda info

RUN conda install --quiet --yes jupyterlab jupyterhub-singleuser nb_conda_kernels && \
    conda clean --all --yes && \
    jupyter --version && \
    jupyterhub --version

EXPOSE 8888/tcp
ENTRYPOINT ["jupyterhub-singleuser"]
CMD [""]

RUN useradd --create-home --no-user-group jovyan
VOLUME /home/jovyan/work
USER jovyan
WORKDIR /home/jovyan/

###################
# Development C++ #
###################

FROM base AS devcpp

USER root
WORKDIR /tmp/

RUN microdnf --assumeyes install gcc gcc-c++ gdb make cmake && \
    microdnf --assumeyes install clang && \
    microdnf --assumeyes install strace && \
    microdnf --assumeyes remove python-unversioned-command && \
    microdnf clean all

USER jovyan
WORKDIR /home/jovyan/

##################
# Stage anaconda #
##################

FROM base AS anaconda

RUN conda create --quiet --yes --name Anaconda anaconda && \
    conda clean --all --yes

###############
# Stage julia #
###############

FROM base AS julia

USER root
WORKDIR /tmp/

## https://github.com/JuliaCI/julia-buildkite/blob/main/utilities/build_envs.sh
## CPU_TARGET="generic;cortex-a76,clone_all"
## CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1);x86-64-v4,-rdrnd,base(1)"

ARG JULIA_CPU_TARGET=native
ARG JULIA_VERSION=1.12
# FIX: JULIA_VERSION=1.12

RUN if [ "x${JULIA_VERSION}" = "xnightly" ]; then \
        JULIA_URL=https://julialangnightlies-s3.julialang.org/bin/linux/$(uname -m) ;\
        JULIA_FILE=julia-latest-linux-$(uname -m).tar.gz ;\
    else \
        if [ "$(uname -m)" = "x86_64"  ]; then \
            JULIA_URL=https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION} ;\
        else \
            JULIA_URL=https://julialang-s3.julialang.org/bin/linux/$(uname -m)/${JULIA_VERSION} ;\
        fi ;\
        JULIA_FILE=julia-${JULIA_VERSION}-latest-linux-$(uname -m).tar.gz ;\
    fi && \
    mkdir /opt/julia-${JULIA_VERSION} && \
    echo ${JULIA_URL}/${JULIA_FILE} && \
    curl --location --remote-name ${JULIA_URL}/${JULIA_FILE} && \
    tar xzf ${JULIA_FILE} -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm ${JULIA_FILE} && \
    ln --symbolic /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia && \
    julia --version

USER jovyan
WORKDIR /home/jovyan/

COPY setup.jl      /opt/
COPY setupAMPL.sh  /opt/
COPY setupORlib.sh /opt/

RUN julia --threads auto --eval "using InteractiveUtils; versioninfo(); @ccall jl_dump_host_cpu()::Cvoid"
RUN julia --threads auto --eval "import Pkg; Pkg.add(\"IJulia\")"
RUN sh /opt/setupORlib.sh
RUN julia --threads auto /opt/setup.jl

###################
# Stage juliacuda #
###################

FROM julia AS juliacuda

ARG JULIA_CPU_TARGET=native

RUN julia --threads auto --eval "using InteractiveUtils; versioninfo(); @ccall jl_dump_host_cpu()::Cvoid"

RUN julia --threads auto <<EOF
    # LocalPreferences
    import Pkg
    filelp = joinpath(homedir(), ".julia/environments")
    filelp = joinpath(filelp, "v\$(Base.VERSION.major).\$(Base.VERSION.minor)")
    mkpath(filelp)
    filelp = joinpath(filelp, "LocalPreferences.toml")
    write(filelp, "[CUDA_Runtime_jll]\nversion = \"13.3\"\n")
    # CUDA_Runtime_jll
    Pkg.add("CUDA_Runtime_jll")
    import CUDA_Runtime_jll
    @show CUDA_Runtime_jll.host_platform
    # CUDA_Compiler_jll
    Pkg.add("CUDA_Compiler_jll")
    import CUDA_Compiler_jll
    @show CUDA_Compiler_jll.host_platform
    # CUDA
    Pkg.add("CUDA")
    import CUDA
    CUDA.precompile_runtime()
EOF

#################
# Stage $TARGET #
#################

FROM ${TARGET} AS final
