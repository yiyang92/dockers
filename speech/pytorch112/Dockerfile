FROM continuumio/miniconda3:4.11.0

# CI build args
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG PIP_INDEX_URL
ARG CI_JOB_TOKEN

# Conda/pip build args
ARG REQ_PATH
ARG CUDA

RUN echo "deb https://apt-proxy.tcsbank.ru/repository/deb-debian/ bullseye main" > /etc/apt/sources.list \
    && echo "deb https://apt-proxy.tcsbank.ru/repository/deb-debian/ bullseye-updates main" >> /etc/apt/sources.list

# Build packages and nvidia drivers compatibility
RUN apt-get update \
    && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        ibverbs-providers \
        libibverbs1 \
        librdmacm1 \
        libsndfile1 \
        vim \
        g++ \
    && apt-get clean

ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}

COPY . /voice-conversion
WORKDIR /voice-conversion

RUN conda config --add channels conda-forge && conda config --set channel_priority strict
RUN conda env create -f ${REQ_PATH}/conda-environment.yaml && conda clean -q -y -a

# Replace the shell binary with activated conda env
RUN echo "conda activate "`conda env list | tail -2 | cut -d' ' -f1` >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Unset proxies
ENV HTTP_PROXY=
ENV HTTPS_PROXY=
ENV http_proxy=
ENV https_proxy=

# Pypi and internal packages
RUN git config --global url."https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.tcsbank.ru".insteadOf https://gitlab.tcsbank.ru 
RUN pip install -r ${REQ_PATH}/requirements.txt && pip install -e . && pip cache purge && rm ~/.gitconfig

# Default entrypoint
CMD ["/bin/bash", "--login"]
