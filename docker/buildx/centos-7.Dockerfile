FROM centos:7
SHELL ["/bin/bash", "-c"]
ARG GOLANG_VERSION=1.21.6

ARG VAULT_URL=https://vault.centos.org/7.9.2009
ARG VAULT_URL_OTHER=https://vault.centos.org/altarch/7.9.2009

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        FINAL_VAULT_URL="$VAULT_URL"; \
    else \
        FINAL_VAULT_URL="$VAULT_URL_OTHER"; \
    fi && \
    echo "Architecture: $ARCH" && \
    echo "Using VAULT_URL: ${FINAL_VAULT_URL}" && \
    sed -i 's/^mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i "s|#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=${FINAL_VAULT_URL}|g" /etc/yum.repos.d/CentOS-Base.repo
    yum install -y epel-release && yum update -y \
 && yum install -y make \
                   git \
                   m4 \
                   curl \
                   wget \
                   unzip \
                   which \
                   xz \
                   patch \
                   python \
                   python-devel \
                   python3 \
                   python3-devel \
                   redhat-lsb-core \
                   perl-Data-Dumper \
                   perl-Thread-Queue \
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
                   ninja-build \
                && yum clean all \
                && rm -rf /var/cache/yum
RUN if ! [ -x "$(command -v ninja)" ]; then ln -s $(which ninja-build) /usr/bin/ninja; fi

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
