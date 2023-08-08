FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
ARG DEBIAN_FRONTEND=noninteractive
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
                       libz-dev \
                       build-essential \
                       libreadline-dev \
                       ncurses-dev \
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

# Install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-$(uname -m).sh \
    && chmod +x cmake-3.20.0-linux-$(uname -m).sh \
    && ./cmake-3.20.0-linux-$(uname -m).sh --skip-license --prefix=/usr/local \
    && rm cmake-3.20.0-linux-$(uname -m).sh

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
