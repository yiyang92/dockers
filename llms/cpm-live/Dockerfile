ARG CUDA_IMAGE=11.7.0-devel-ubuntu18.04
FROM nvidia/cuda:${CUDA_IMAGE} as cuda_source
FROM continuumio/miniconda3:22.11.1

# Proxy (if needed), args only used during building as --build-arg
ARG HTTP_PROXY
ARG HTTPS_PROXY=${HTTP_PROXY}
ARG http_proxy=${HTTP_PROXY}
ARG https_proxy=${HTTP_PROXY}

# Build packages
RUN apt-get update \
    && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        ibverbs-providers \
        libibverbs1 \
        librdmacm1 \
        vim \
        g++ \
        unzip \
        neofetch \
        man \
        file \
    && apt-get clean

# Copy cuda devel from nvidia docker
ARG CUDA=11.7
ENV CUDA_HOME=/usr/local/cuda-${CUDA}
COPY --from=cuda_source ${CUDA_HOME} ${CUDA_HOME}

COPY . /requirements
WORKDIR /requirements

RUN conda config --set channel_priority strict && \
    conda env create -f conda-environment.yaml && conda clean -q -y -a

# Replace the shell binary with activated conda env
RUN echo "conda activate "`conda env list | tail -2 | cut -d' ' -f1` >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Default entrypoint
CMD ["/bin/bash", "--login"]

