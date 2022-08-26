FROM ubuntu:16.04
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

ENV NG_URL=https://raw.githubusercontent.com/dutor/nebula-gears/master/install
ENV OSS_UTIL_URL=http://gosspublic.alicdn.com/ossutil/1.7.13/ossutil64
ENV PACKAGE_DIR=/usr/src/third-party
RUN set -o pipefail && curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY oss-upload.sh ${PACKAGE_DIR}/oss-upload.sh
RUN chmod +x ${PACKAGE_DIR}/oss-upload.sh

RUN wget -q -O /usr/bin/ossutil64 ${OSS_UTIL_URL}
RUN chmod +x /usr/bin/ossutil64
