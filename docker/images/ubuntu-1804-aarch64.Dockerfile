FROM arm64v8/ubuntu:18.04
SHELL ["/bin/bash", "-c"]
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
ENV OSS_UTIL_URL='https://gosspublic.alicdn.com/ossutil/1.7.0/ossutilarm64?spm=a2c63.p38356.879954.15.c0942454HuAZDI'
ENV PACKAGE_DIR=/usr/src
RUN set -o pipefail && curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY build-third-party.sh ${PACKAGE_DIR}/build-third-party.sh
RUN chmod +x ${PACKAGE_DIR}/build-third-party.sh

COPY oss-upload.sh ${PACKAGE_DIR}/oss-upload.sh
RUN chmod +x ${PACKAGE_DIR}/oss-upload.sh

RUN wget -q -O /usr/bin/ossutil64 ${OSS_UTIL_URL}
RUN chmod +x /usr/bin/ossutil64
