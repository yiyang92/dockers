ARG CUDA_IMAGE
FROM nvidia/cuda:${CUDA_IMAGE} as cuda_source

# Proxy (if needed)
ARG HTTP_PROXY
ENV HTTPS_PROXY=${HTTP_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTP_PROXY}

# Build packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        ibverbs-providers \
        libibverbs1 \
        librdmacm1 \
        libsndfile1 \
        openssh-client \
        openssh-server \
        software-properties-common \
        vim \
        g++ \
    && apt-get clean

# Default entrypoint
CMD ["/bin/bash", "--login"]
