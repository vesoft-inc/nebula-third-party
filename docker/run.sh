#! /usr/bin/env bash

this_dir=$(dirname $(readlink -f $0))
build_root=$(pwd)
package_dir=$build_root/packages
version=5.0

function atexit() {
    compgen -G $package_dir/vesoft-third-party-*.sh &> /dev/null
    if [[ $? -ne 0 ]]
    then
        exit 1
    fi

    cp -v $package_dir/vesoft-third-party-*.sh /data
    [[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh third-party/$version $package_dir/vesoft-third-party-*.sh
}

trap atexit EXIT

set -e

arch=$(uname -m)

nebula-gears-update

git clone -b $version --depth=1 https://github.com/vesoft-inc/nebula-third-party.git

gcc_versions=${USE_GCC_VERSIONS:-7.5.0,8.3.0,9.1.0,9.2.0,9.3.0,10.1.0}
install-gcc --version=$gcc_versions

install-cmake
source /opt/vesoft/toolset/cmake/enable

for v in $(echo $gcc_versions | tr ',' ' ')
do
    source /opt/vesoft/toolset/gcc/$v/enable
    rm -rf /opt/vesoft/third-party
    build_package=1 disable_cxx11_abi=0 nebula-third-party/build.sh /opt/vesoft/third-party/$version
    if [[ $arch = 'x86_64' ]]
    then
        rm -rf ./build
        rm -rf /opt/vesoft/third-party
        build_package=1 disable_cxx11_abi=1 nebula-third-party/build.sh /opt/vesoft/third-party/$version
    fi
    source /opt/vesoft/toolset/gcc/$v/disable
done
