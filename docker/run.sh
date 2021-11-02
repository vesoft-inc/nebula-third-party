#! /usr/bin/env bash

this_dir="$(cd "$(dirname "$0")" && pwd)"
build_root=$(pwd)
package_dir=$build_root/packages

function atexit() {
    compgen -G $package_dir/vesoft-third-party-*.sh &> /dev/null
    if [[ $? -ne 0 ]]
    then
        exit 1
    fi

    # cp -v $package_dir/vesoft-third-party-*.sh /data
    ${this_dir}/oss-upload.sh third-party/2.0 $package_dir/vesoft-third-party-*.sh
}

trap atexit EXIT

set -ex

arch=$(uname -m)

nebula-gears-update

versions=${USE_GCC_VERSIONS:-7.5.0,8.3.0,9.1.0,9.2.0,9.3.0,10.1.0}
install-gcc --version=$versions

install-cmake
source /opt/vesoft/toolset/cmake/enable

for v in $(echo $versions | tr ',' ' ')
do
    source /opt/vesoft/toolset/gcc/$v/enable
    rm -rf /opt/vesoft/third-party
    build_package=1 disable_cxx11_abi=0 $this_dir/../build.sh /opt/vesoft/third-party
    if [[ $arch = 'x86_64' ]]
    then
        rm -rf /opt/vesoft/third-party
        build_package=1 disable_cxx11_abi=1 $this_dir/../build.sh /opt/vesoft/third-party
    fi
    source /opt/vesoft/toolset/gcc/$v/disable
done
