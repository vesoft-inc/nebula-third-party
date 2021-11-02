FROM ubuntu:16.04

ARG USE_GCC_VERSIONS=""
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]
RUN apt-get clean
RUN apt-get update
RUN apt-get install -y make \
                       git \
                       m4 \
                       wget \
                       unzip \
                       xz-utils \
                       patch \
                       python \
                       curl \
                       python-dev \
                       lsb-core \
                       libz-dev \
                       build-essential \
                       libreadline-dev \
                       ncurses-dev \
                       build-essential \
                       cmake \
                       libtool \
                       automake \
                       autoconf \
                       autoconf-archive \
                       autotools-dev \
                       bison \
                       flex \
                       gperf \
                       gettext

ENV NG_URL=https://raw.githubusercontent.com/vesoft-inc/nebula-gears/master/install
ENV OSS_UTIL_URL=http://gosspublic.alicdn.com/ossutil/1.6.10/ossutil64
ENV PACKAGE_DIR=/usr/src
RUN set -o pipefail && curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY . ${PACKAGE_DIR}

RUN chmod +x ${PACKAGE_DIR}/docker/oss-upload.sh

RUN wget -q -O /usr/bin/ossutil64 ${OSS_UTIL_URL}
RUN chmod +x /usr/bin/ossutil64

RUN --mount=type=secret,id=ossutilconfig,target=$HOME/.ossutilconfig bash ${PACKAGE_DIR}/docker/run.sh