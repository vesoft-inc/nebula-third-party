FROM ubuntu:16.04
ARG DEBIAN_FRONTEND=noninteractive
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
SHELL ["/bin/bash", "-c"]
RUN apt-get update \
 && apt-get install -y make \
                       git \
                       m4 \
                       curl \
                       wget \
                       unzip \
                       which \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-$(uname -m).sh \
    && chmod +x cmake-3.20.0-linux-$(uname -m).sh \
    && ./cmake-3.20.0-linux-$(uname -m).sh --skip-license --prefix=/usr/local \
    && rm cmake-3.20.0-linux-$(uname -m).sh

# Install ossutil
RUN curl https://gosspublic.alicdn.com/ossutil/install.sh | bash

ENV PACKAGE_DIR=/usr/src/third-party
RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

