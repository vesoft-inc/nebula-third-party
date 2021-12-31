#! /usr/bin/env bash
#
# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.


# Use CC and CXX environment variables to use custom compilers.

start_time=$(date +%s)

# Always use bash
shell=$(basename $(readlink /proc/$$/exe))
if [ ! x$shell = x"bash" ] && [[ x$shell != x"qemu-aarch64"* ]]
then
    bash $0 $@
    exit $?
fi

this_dir=$(dirname $(readlink -f $0))

# CMake and GCC version checking
function version_cmp {
    mapfile -t left < <( echo $1 | tr . '\n' )
    mapfile -t right < <( echo $2 | tr . '\n')
    local i
    for i in ${!left[@]}
    do
        local lv=${left[$i]}
        local rv=${right[$i]}
        [[ -z $rv ]] && { echo $lv; return; }
        [[ $lv -ne $rv ]] && { echo $((lv - rv)); return; }
    done
    ((i++))
    rv=${right[$i]}
    [[ ${#right[@]} -gt ${#left[@]} ]] && { echo $((0-rv)); return; }
}

function check_cmake {
    hash cmake &> /dev/null || { echo "No cmake found." 1>&2; exit 1; }
    local cmake_version=$(cmake --version | head -1 | cut -d ' ' -f 3)
    local least_cmake_version=3.5.0
    if [[ $(version_cmp $cmake_version $least_cmake_version) -lt 0 ]]
    then
        echo "cmake $least_cmake_version or higher required" 1>&2
        exit 1
    fi
}

function check_cxx {
    # TODO To consider clang++
    local cxx_cmd
    hash g++ &> /dev/null && cxx_cmd=g++
    [[ -n $CXX ]] && cxx_cmd=$CXX
    [[ -z $cxx_cmd ]] && { echo "No C++ compiler found" 1>&2; exit 1; }
    cxx_version=$($cxx_cmd -dumpfullversion -dumpversion 2>/dev/null)
    local least_cxx_version=7.5.0
    if [[ $(version_cmp $cxx_version $least_cxx_version) -lt 0 ]]
    then
        echo "g++ $least_cxx_version or higher required, but you have $cxx_version" 1>&2
        exit 1
    fi
}

check_cmake
check_cxx

# Directories setup
version=3.0
cur_dir=`pwd`
source_dir=$this_dir/project
build_root=$cur_dir
build_dir=$build_root/build
package_dir=$build_root/packages
prefix=$1
install_dir=${prefix:-$build_root/install}
download_dir=$build_root/tarballs
source_tar_name=nebula-third-party-src-$version.tgz
source_url=https://oss-cdn.nebula-graph.com.cn/third-party/${source_tar_name}
logfile=$build_root/build.log
cxx_cmd=${CXX:-g++}
gcc_version=$(${CXX:-g++} -dumpfullversion -dumpversion)
abi_version=$($this_dir/cxx-compiler-abi-version.sh)
libc_version=$(ldd --version | head -1 | cut -d ' ' -f4 | cut -d '-' -f1)

export PATH=$install_dir/bin:$PATH
export PKG_CONFIG_PATH=$install_dir/lib/pkgconfig:$install_dir/lib64/pkgconfig:$PKG_CONFIG_PATH

# Exit on any failure here after
set -e
set -o pipefail

trap '[[ $? -ne 0 ]] && echo "Building failed, see $logfile for more details." 1>&2' EXIT

# Allow to customize compilers
[[ -n ${CC} ]] && C_COMPILER_ARG="-DCMAKE_C_COMPILER=${CC}"
[[ -n ${CXX} ]] && CXX_COMPILER_ARG="-DCMAKE_CXX_COMPILER=${CXX}"
[[ ${disable_cxx11_abi} -ne 0 ]] && DISABLE_CXX11_ABI="-DDISABLE_CXX11_ABI=1"
export disable_cxx11_abi

# Download source archives if necessary
mkdir -p $build_root
cd $build_root

if [[ -f $source_tar_name ]]
then
    checksum=$(md5sum $source_tar_name | cut -d ' ' -f 1)
fi

# NOTE Please adjust the expected checksum once the source tarball changed
if [[ ! $checksum = a94165e0ba71e6da62421037770fa40e ]]
then
    hash wget &> /dev/null && download_cmd="wget -c"
    if [[ -z $download_cmd ]]
    then
        echo "'wget' not found for downloading" 1>&2;
    elif ! bash -c "$download_cmd $source_url"
    then
        # Resort to the builtin download method of cmake on failure
        echo "Download from $source_url failed." 1>&2
    else
        echo "Source of third party was downdloaded to $build_root"
        echo -n "Extracting into $download_dir..."
        tar -xzf $source_tar_name
        echo "done"
    fi
else
    tar -xzf $source_tar_name
fi

# Build and install
mkdir -p $build_dir $install_dir $package_dir
cd $build_dir

echo "Starting build"

cmake -DDOWNLOAD_DIR=$download_dir              \
      -DCMAKE_INSTALL_PREFIX=$install_dir       \
      -DSOURCE_PREFIX=$source_dir               \
      ${C_COMPILER_ARG} ${CXX_COMPILER_ARG}     \
      ${DISABLE_CXX11_ABI}                      \
      $source_dir |& tee $logfile

make |& \
         tee -a $logfile | \
        { grep --line-buffered 'Creating\|^Scanning\|Performing\|Completed\|CMakeFiles.*Error' || true; }
end_time=$(date +%s)

# We are going to keep the build files so that next time it does not have to
# re-build everything. If you want to rebuild everything, simply remove the
# build directory
#cd $OLDPWD && rm -rf $build_dir

# Remove all libtool files
find $install_dir -name '*.la' | xargs rm -f

# Remove big unneeded binaries
binaries+=(k{rb5-onfig,init,admin,su,tutil,list,vno,passwd})
binaries+=(k{destroy,switch,5srvutil,eyctl})
binaries+=(openssl gss-client dump_syms_mac)
binaries+=(uuclient sim_client)
binaries+=(sclient compile_et)
binaries+=(c_rehash gflags_completions.sh)
binaries+=(curl curl-config)

binaries+=(proxygen_{echo,push,proxy,static,curl})

binaries+=(db_{archive,checkpoint,deadlock,dump,hotbackup,load})
binaries+=(db_{log_verify,printlog,recover,replicate,stat,upgrade,verify})

binaries+=(bzip2 bunzip2 bzip2recover bz{cat,cmp,diff,less,more,grep,egrep,fgrep})
binaries+=(lz4 lz4c lz4cat unlz4 lz{cat,cmp,diff,less,more,grep,egrep,fgrep})
binaries+=(lzma unlzma lzma{dec,info})
binaries+=(zstd zstdgrep)
binaries+=(xz unxz xz{cat,cmp,dec,diff,less,more,grep,egrep,fgrep})

for file in ${binaries[@]}
do
    rm -f $install_dir/bin/$file
done

binaries=()
binaries+=(key.dns_resolver request-key k{prop,proplog,propd,admin.local,admind})
binaries+=(request-key uuserver sserver sim_server gss-server)
binaries+=(slap{acl,add,auth,cat,dn,index,passwd,schema,test})
for file in ${binaries[@]}
do
    rm -f $install_dir/sbin/$file
done

binaries=()
binaries+=(slapd)
for file in ${binaries[@]}
do
    rm -f $install_dir/libexec/$file
done

# Strip executables
for file in $install_dir/bin/*
do
    file $file | grep ELF >/dev/null &&  strip --strip-unneeded $file
done

# Remove unneeded static libraries
#libs+=(libmstch.a libmustache_lib.a)
#for lib in ${libs[@]}
#do
#    rm -f $install_dir/lib/$lib
#    rm -f $install_dir/lib64/$lib
#done

# Remove CMake configs of boost
rm -rf $install_dir/lib/cmake/[Bb]oost*

march=$(uname -m)

# Make krb5 relocatable

cat > $install_dir/version-info <<EOF
Package         : Nebula Third Party
Version         : $version
Date            : $(date)
glibc           : $libc_version
Arch            : $march
Compiler        : GCC $gcc_version
C++ ABI         : $abi_version
Vendor          : VEsoft Inc.
EOF

function make_package {
    exec_file=$package_dir/vesoft-third-party-$version-$march-libc-$libc_version-gcc-$gcc_version-abi-$abi_version.sh

    echo "Creating self-extractable package $exec_file"
    cat > $exec_file <<EOF
#! /usr/bin/env bash
set -e

hash xz &> /dev/null || { echo "xz: Command not found"; exit 1; }

[[ \$# -ne 0 ]] && prefix=\$(echo "\$@" | sed 's;.*--prefix=(\S*).*;\1;p' -rn)
prefix=\${prefix:-/opt/vesoft/third-party/$version}
mkdir -p \$prefix

[[ -w \$prefix ]] || { echo "\$prefix: No permission to write"; exit 1; }

archive_offset=\$(awk '/^__start_of_archive__$/{print NR+1; exit 0;}' \$0)
tail -n+\$archive_offset \$0 | tar --no-same-owner --numeric-owner -xJf - -C \$prefix

echo "Nebula Third Party has been installed to \$prefix"

exit 0

__start_of_archive__
EOF
    cd $install_dir
    tar -cJf - * >> $exec_file
    chmod 0755 $exec_file
    cd $OLDPWD
}

[[ $build_package -ne 0 ]] && make_package

echo
echo "Third parties have been successfully installed to $install_dir"
echo "$((end_time - start_time)) seconds been taken."
