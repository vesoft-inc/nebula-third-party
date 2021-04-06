#! /usr/bin/env bash

this_dir=$(dirname $(readlink -f $0))

function atexit() {
    compgen -G third-party/vesoft-third-party-*.sh &> /dev/null
    if [[ $? -ne 0 ]]
    then
        exit 1
    fi

    cp -v third-party/vesoft-third-party-*.sh /data
    [[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh third-party/2.0 third-party/vesoft-third-party-*.sh
}

trap atexit EXIT

set -e

arch=$(uname -m)

nebula-gears-update

git clone --depth=1 https://github.com/dutor/nebula-third-party.git

versions=${USE_GCC_VERSIONS:-7.5.0,8.3.0,9.1.0,9.2.0,9.3.0,10.1.0}
install-gcc --version=$versions

if [[ $arch = 'x86_64' ]]
then
    nebula-third-party/install-cmake.sh
    export PATH=$PWD/cmake-3.15.5/bin:$PATH
else
    wget https://oss-cdn.nebula-graph.com.cn/toolset/vesoft-cmake-3.15.7-aarch64-glibc-2.17.sh
    bash vesoft-cmake-3.15.7-aarch64-glibc-2.17.sh
    source /opt/vesoft/toolset/cmake/enable
fi

for v in $(echo $versions | tr ',' ' ')
do
    source /opt/vesoft/toolset/gcc/$v/enable
    rm -rf /opt/vesoft/third-party
    build_package=1 disable_cxx11_abi=0 nebula-third-party/build-third-party.sh /opt/vesoft/third-party
    if [[ $arch = 'x86_64' ]]
    then
        rm -rf /opt/vesoft/third-party
        build_package=1 disable_cxx11_abi=1 nebula-third-party/build-third-party.sh /opt/vesoft/third-party
    fi
    source /opt/vesoft/toolset/gcc/$v/disable
done
