FROM centos:7
SHELL ["/bin/bash", "-c"]
RUN yum install -y epel-release && yum update -y \
 && yum install -y make \
                   git \
                   m4 \
                   curl \
                   wget \
                   unzip \
                   xz \
                   patch \
                   python3 \
                   python3-devel \
                   python \
                   python-devel \
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
                   which \
                   gperf \
                   gettext \
                   ninja-build \
                && yum clean all \
                && rm -rf /var/cache/yum

RUN if ! [ -x "$(command -v ninja)" ]; then ln -s $(which ninja-build) /usr/bin/ninja; fi

# Install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-$(uname -m).sh \
    && chmod +x cmake-3.20.0-linux-$(uname -m).sh \
    && ./cmake-3.20.0-linux-$(uname -m).sh --skip-license --prefix=/usr/local \
    && rm cmake-3.20.0-linux-$(uname -m).sh

# Install libdwarf-20200114
RUN wget --no-check-certificate https://www.prevanders.net/libdwarf-20200114.tar.gz \
    && tar -xzf libdwarf-20200114.tar.gz \
    && cd libdwarf-20200114 \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf libdwarf-20200114 libdwarf-20200114.tar.gz

ENV PACKAGE_DIR=/usr/src/third-party
RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}
