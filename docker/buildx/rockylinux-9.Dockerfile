FROM rockylinux:9
SHELL ["/bin/bash", "-c"]
ARG GOLANG_VERSION=1.21.6

RUN dnf install -y epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf update -y

# Install development tools and dependencies
RUN dnf install -y make \
                   git \
                   m4 \
                   wget \
                   unzip \
                   which \
                   xz \
                   patch \
                   python3 \
                   python3-devel \
                   perl-Data-Dumper \
                   perl-Thread-Queue \
                   perl-FindBin \
                   readline-devel \
                   ncurses-devel \
                   zlib-devel \
                   gcc \
                   gcc-c++ \
                   libtool \
                   autoconf \
                   autoconf-archive \
                   automake \
                   bison \
                   flex \
                   gperf \
                   gettext \
                   libstdc++-devel \
                   libstdc++-static \
                   ninja-build \
                   texinfo \
                   file \
                   lsb-release \
   && dnf clean all && rm -rf /var/cache/dnf

# Install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.23.5/cmake-3.23.5-linux-$(uname -m).sh \
    && chmod +x cmake-3.23.5-linux-$(uname -m).sh \
    && ./cmake-3.23.5-linux-$(uname -m).sh --skip-license --prefix=/usr/local \
    && rm cmake-3.23.5-linux-$(uname -m).sh

# Install golang
RUN ARCH="$(uname -m)"; \
    case "${ARCH}" in \
        x86_64) GOARCH='amd64';; \
        aarch64) GOARCH='arm64';; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1;; \
    esac; \
    curl -L https://go.dev/dl/go${GOLANG_VERSION}.linux-${GOARCH}.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

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
