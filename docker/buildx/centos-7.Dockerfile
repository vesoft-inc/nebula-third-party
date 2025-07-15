FROM centos:7
SHELL ["/bin/bash", "-c"]
ARG GOLANG_VERSION=1.21.6
RUN sed -i 's/^mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i "s|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-Base.repo && \
    yum install -y epel-release && yum update -y && \
    yum install -y make \
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

# Install GCC 9.5.0
RUN export URL=https://raw.githubusercontent.com/vesoft-inc/nebula-gears/master/install && \
    bash <(curl -Ls $URL) && \
    install-gcc --version=9.5.0

ENV TOOLSET_GCC_DIR=/opt/vesoft/toolset/gcc/9.5.0
ENV CC=${TOOLSET_GCC_DIR}/bin/gcc
ENV CXX=${TOOLSET_GCC_DIR}/bin/g++
ENV PATH=${TOOLSET_GCC_DIR}/bin:${PATH}
ENV LD_LIBRARY_PATH=${TOOLSET_GCC_DIR}/lib64:${LD_LIBRARY_PATH}

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
