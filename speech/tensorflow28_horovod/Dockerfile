ARG CUDA_IMAGE
FROM nvidia/cuda:${CUDA_IMAGE} as cuda_source
FROM continuumio/miniconda3:4.10.3

ARG HTTP_PROXY
ARG PIP_INDEX_URL
ARG CI_JOB_TOKEN
ARG CUDA

# Conda/pip build args
ARG REQ_PATH

ENV APT_PROXY_CONF_RAW="Acquire { HTTP::Proxy \"$HTTP_PROXY\"; HTTPS::Proxy \"$HTTP_PROXY\"; }"
ENV APT_PROXY_CONF=${HTTP_PROXY:+$APT_PROXY_CONF_RAW}
RUN echo $APT_PROXY_CONF > /etc/apt/apt.conf.d/proxy.conf && \
    cat /etc/apt/apt.conf.d/proxy.conf

ENV HTTP_PROXY=${HTTP_PROXY:-""}
ENV HTTPS_PROXY=${HTTP_PROXY:-""}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}

# Nvidia repositories
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
    && dpkg -i cuda-keyring_1.0-1_all.deb && rm cuda-keyring_1.0-1_all.deb

# OpenSSH for MPI to communicate between containers, cuda-compat - for old drivers compatibility
RUN apt-get update && \
    export CUDA_COMPAT="cuda-compat-`echo ${CUDA} | sed 's/\./-/'`" && \
    apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        gcc-8 \
        g++-8 \
        make \
        gnupg2 \
        ibverbs-providers \
        libibverbs1 \
        librdmacm1 \
        libsndfile1 \
        openssh-client \
        openssh-server \
        software-properties-common \
        ${CUDA_COMPAT} \
        vim \
        && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
        && ln -s /usr/bin/g++-8 /usr/bin/g++ \
        && apt-get clean

RUN wget https://ca-certs.tcsbank.ru/v0/tinkoff-root.crt -O /usr/local/share/ca-certificates/tinkoff-root.crt && \
    wget https://ca-certs.tcsbank.ru/v0/tinkoff-bundle.crt -O /usr/local/share/ca-certificates/tinkoff-bundle.crt && \
    update-ca-certificates

# Allow OpenSSH to talk to containers without asking for confirmation
RUN mkdir -p /var/run/sshd && cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config

COPY . /tts-tacotron
WORKDIR /tts-tacotron

# Copy cuda devel from nvidia docker
ENV CUDA_HOME=/usr/local/cuda-${CUDA}
COPY --from=cuda_source ${CUDA_HOME} ${CUDA_HOME}

# Conda dependencies installation
ENV ENV_NAME="tts-tacotron"
RUN conda update -q -y -n base -c defaults conda && \
    CONDA_CUDA_OVERRIDE=${CUDA} \
    conda env create --file ${REQ_PATH}/conda-environment.yaml \
    && conda clean -q -y -a

# Replace the shell binary with activated conda env
RUN printf ". /opt/conda/etc/profile.d/conda.sh\nconda activate ${ENV_NAME}\n"> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Install Horovod + requirements 
# Horovod should be compiled with NCCL support for multi-gpu training
# Nccl binary is installed in anaconda environment
# Build status can be checked with horovodrun -cb
ENV CONDA_ENV=/opt/conda/envs/${ENV_NAME}
ENV HOROVOD_CUDA_HOME=${CUDA_HOME}
ENV HOROVOD_NCCL_HOME=${CONDA_ENV}
# Let the compiler know where to look for shared libraries (conda + cuda spaths)
# We set the variables for horovod building to set the support modes
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${CONDA_ENV}/lib"
RUN ln -s ${HOROVOD_CUDA_HOME} /usr/local/cuda && \
    ldconfig && HOROVOD_NCCL_LINK=SHARED \
    HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 HOROVOD_GPU_OPERATIONS=NCCL \
    HOROVOD_WITHOUT_GLOO=1 HOROVOD_WITHOUT_MXNET=1 HOROVOD_WITHOUT_PYTORCH=1 \
    pip install -r requirements/requirements.txt && pip cache purge && horovodrun -cb

# Unset proxies
ENV HTTP_PROXY=
ENV HTTPS_PROXY=
ENV http_proxy=
ENV https_proxy=

# Pypi and internal packages
RUN git config --global url."https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.tcsbank.ru".insteadOf https://gitlab.tcsbank.ru && \
    pip install -e . && pip cache purge && rm ~/.gitconfig

# Default entrypoint
CMD ["/bin/bash", "--login"]
