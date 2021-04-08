# Provides
 * folly
 * fbthrift
 * proxygen
 * wangle
 * fizz
 * fatal
 * sodium
 * RocksDB
 * jemalloc
 * double-conversion
 * fmt
 * glog
 * gflags
 * googletest
 * googlebenchmark
 * snappy
 * s2geometry
 * bzip2
 * zstd
 * lz4
 * lzma
 * zlib
 * openssl
 * libevent
 * libunwind
 * boost
 * simdjson
 * capstone
 * flex
 * bison

# How to Build

## Build Requirements

 * Access to the Internet
 * Platform: x86_64 or aarch64(i.e. arm64v8), `uname -m`
 * OS: Linux 3.10+, `uname -r`
 * Compiler: GCC 7.5.0+, `g++ --version`
 * libc: glibc 2.17+, `ldd --version`
 * Build tools: CMake 3.5+, `cmake --version`

Other dependencies:
 * Python 3+


## Build Third Party

### Prepare
```shell
$ git clone https://github.com/vesoft-inc/nebula-third-party.sh
$ path=$(pwd)/nebula-third-party
$ mkdir build && cd build
```

### Native Build
```shell
$ build_package=1 $path/build.sh
$ ls
install/ tarballs/  packages/ nebula-third-party-src-2.0.tgz
$ ls packages
vesoft-third-party-2.0-x86_64-libc-xxx-gcc-xxx-abi-11.sh

# You could also specify an install prefix
$ build_package=1 $path/build.sh /opt/vesoft/third-party/2.0
```

### Docker-based Build
```shell
# Print all targets
$ make -C $path/build print
centos-7 centos-8 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2010

# Build specific target
$ make -C $path/build centos-7

# Build all targets
$ make -C $path/build all

# Build with specified versions of GCC
$ USE_GCC_VERSIONS=7.5.0,10.1.0 make -C $path/build

# All built packages resides in packages/
$ ls packages
vesoft-third-party-2.0-x86_64-libc-xxx-gcc-xxx-abi-11.sh ...
```

**NOTE**:
 * If OSS credential were setup properly in `$HOME/.ossutilconfig`, all built packages will be uploaded to `oss://nebula-graph/third-party/2.0`
 * Invoke with `make -ik` to continue to build the next target even if some target fails.
 * Packages for different architectures(x86_64, aarch64) need to be built separately on the target machine.


## Build the Docker Images
```shell
$ make -C $path/docker
```

**NOTE**:
 * Rules are the same as building the third parties.
 * All docker images will be pushed to vesoft/third-party-build.
 * You should have logged in DockerHub in advance and have write access to the repository vesoft/third-party-build.
 * Images for different architectures(x86_64, aarch64) need to be built separately one the target machine.
