FROM rockylinux:8
SHELL ["/bin/bash", "-c"]
ARG GOLANG_VERSION=1.21.6
RUN yum install -y epel-release yum-utils &&  yum config-manager --set-enabled powertools && yum update -y \
 && yum install -y make \
                   git \
                   m4 \
                   curl \
                   wget \
                   unzip \
                   which \
                   xz \
                   patch \
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
   && yum --enablerepo=powertools install -y ninja-build \
   && yum clean all && rm -rf /var/cache/yum

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

ENV PACKAGE_DIR=/usr/src/third-party    
RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

