FROM ubuntu:22.04
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
RUN apt update \
     && apt install -y make \
                       git \
                       m4 \
                       curl \
                       wget \
                       unzip \
                       xz-utils \
                       patch \
                       python3 \
                       python3-dev \
                       lsb-core \
                       zlib1g-dev \
                       build-essential \
                       libreadline-dev \
                       libncurses-dev \
                       cmake \
                       libtool \
                       automake \
                       autoconf \
                       autoconf-archive \
                       autotools-dev \
                       bison \
                       flex \
                       gperf \
                       gettext \
                       ninja-build \
                       libdwarf-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install ossutil
RUN curl https://gosspublic.alicdn.com/ossutil/install.sh | bash

# Install MinIO Client
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        curl -O https://dl.min.io/client/mc/release/linux-arm64/mc; \
    else \
        curl -O https://dl.min.io/client/mc/release/linux-amd64/mc; \
    fi \
    && chmod +x mc \
    && mv mc /usr/local/bin

ENV PACKAGE_DIR=/usr/src/third-party
RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}
