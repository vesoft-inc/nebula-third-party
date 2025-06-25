# Provides
 * berkeleydb
 * bison
 * boost
 * breakpad
 * bzip2
 * capstone
 * date
 * double-conversion
 * fatal
 * fbthrift
 * fizz
 * flex
 * fmt
 * folly
 * gflags
 * glog
 * googlebenchmark
 * googletest
 * gperf
 * inja
 * jemalloc
 * jwt-cpp
 * ldap
 * libcurl
 * libdwarf
 * libevent
 * libunwind
 * lz4
 * lzma
 * mstch
 * nlohmann-json
 * openssl
 * proxygen
 * rocksdb
 * s2geometry
 * simdjson
 * snappy
 * sodium
 * tomlplusplus
 * valijson
 * wangle
 * yaml-cpp
 * zlib
 * zstd
 * robin-hood-hashing
 * libev
 * xsimd
 * duckdb
 * utf8proc
 * apache-arrow
 * cppjieba
 * limonp

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

**NOTE**:
 * If you run `ls /usr/include/ | grep python`, output `python3.*m` instead of `python3.*`. And if build failed because of `fatal error: pyconfig.h: No such file or directory`, You can `cd /usr/include` and `ln -s python3.*m python3.*` (replace with your version).

## Build Third Party

### Prepare
```shell
$ git clone https://github.com/vesoft-inc/nebula-third-party.git
$ path=$(pwd)/nebula-third-party
$ mkdir build && cd build
```

### Native Build
```shell
$ build_package=1 $path/build.sh
$ ls
install/ tarballs/  packages/ nebula-third-party-src-5.0.tgz
$ ls packages
vesoft-third-party-5.0-x86_64-libc-xxx-gcc-xxx-abi-11.sh

# You could also specify an install prefix
$ build_package=1 $path/build.sh /opt/vesoft/third-party/5.0
```

### Docker-based Build
The docker-based build is for building pre-built packages of third parties. For each target(OS or glibc), it uses different version of GCC to perform the build.
```shell
# Print all targets
$ make -C $path/build print
centos-7 centos-8 rockylinux-8 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2204

# Build specific target
$ make -C $path/build centos-7

# Build all targets
$ make -C $path/build all

# Build with specified versions of GCC
$ USE_GCC_VERSIONS=7.5.0,10.1.0 make -C $path/build

# All built packages resides in packages/
$ ls packages
vesoft-third-party-5.0-x86_64-libc-xxx-gcc-xxx-abi-11.sh ...
```

**NOTE**:
 * If OSS credential were setup properly in `$HOME/.ossutilconfig`, all built packages will be uploaded to `oss://nebula-graph/third-party/5.0`
 * Invoke with `make -ik` to continue to build the next target even if some target fails.
 * Packages for different architectures(x86_64, aarch64) need to be built separately on the target machine.
 * It's always a bad idea to run a Docker container whose native kernel is newer than the hosting system's, e.g. Ubuntu 1804 container on Centos 7 host.
 * Currently, available GCC versions are: 7.5.0, 8.3.0, 9.1.0, 9.2.0, 9.3.0 and 10.1.0.
 * Currently, available glibc versions are: 2.17(Centos 7), 2.23(Ubuntu 16.04), 2.27(Ubuntu 18.04), 2.31(Ubuntu 20.04) and 2.32(Ubuntu 20.10).


## Build the Docker Images
```shell
$ make -C $path/docker
```

**NOTE**:
 * Rules are the same as building the third parties.
 * All docker images will be pushed to vesoft/third-party-build.
 * You should have logged in DockerHub in advance and have write access to the repository vesoft/third-party-build.
 * Images for different architectures(x86_64, aarch64) need to be built separately on the target machine.


# How to Install Pre-built Packages
You could invoke the `install-third-party.sh` script to install a pre-built package of third party. It automatically chooses an applicable version for your environment,
according to the version of GCC and glibc.

```bash
# Check the GCC version
$ g++ --version
g++ (GCC) 9.3.1 20200408 (Red Hat 9.3.1-2)
...

# Check the glibc version
$ ldd --version
ldd (GNU libc) 2.29
...

# Download and install
$ nebula-third-party/install-third-party.sh
...
$ ls /opt/vesoft/third-party/5.0
version-info bin/ include/ lib/ lib64 share/

# Check the version info of the installed package
$ cat /opt/vesoft/third-party/5.0/version-info
Package         : Nebula Third Party
Version         : 5.0
glibc           : 2.27
Arch            : x86_64
Compiler        : GCC 8.3.0
C++ ABI         : 11
Vendor          : VEsoft Inc.

# Install to customized directory
$ nebula-third-party/install-third-party.sh --prefix=/path/to/install

# Install with a customized GCC
$ CXX=/path/to/gcc/bin/g++ nebula-third-party/install-third-party.sh
```

**NOTE**:
 * Because `sudo` doesn't pass environment variables by default, you need pass `CXX` with the `-E` option if you are using a non-default compiler setup. Like,
 `sudo -E CXX=/path/to/g++ install-third-party.sh --prefix=/opt/vesoft/third-party/5.0`
 * Nebula Graph requires C++17 support to build. Although GCC 7.x announces to fully support C++17, it does not stablize until GCC 9.x. Please refer to [here](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=99952) as an example. We suggest to use GCC 9.x or higher to build Nebula Graph. Otherwise, please ensure that you use a compiler which matches the one used to build the pre-built package.
 * the deps of the NeoKylin on mips64el
    - glibc-static.mips64el
    - glibc-n32-devel.mips64el
    - gperf
