cmake_minimum_required(VERSION 3.0.0)
project("Nebula Third Party")
include(ExternalProject)

cmake_host_system_information(RESULT NCPU QUERY NUMBER_OF_PHYSICAL_CORES)
if (NOT NCPU OR NCPU EQUAL 0)
    set(NCPU 1)
endif()

message(STATUS "CXX: $ENV{CXX}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER}")

option(WITH_PIC "Whether to build PIC archive" OFF)

set(common_cmake_args
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} -fPIC"
    "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} -fPIC"
    -DCMAKE_INCLUDE_PATH=${CMAKE_INSTALL_PREFIX}/include
    -DCMAKE_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib
)

set(common_configure_args
    --prefix=${CMAKE_INSTALL_PREFIX}
)

set(common_configure_envs
    "env"
    "CC=${CMAKE_C_COMPILER}"
    "CXX=${CMAKE_CXX_COMPILER}"
    "CFLAGS=${CMAKE_C_FLAGS} -fPIC -O3"
    "CXXFLAGS=${CMAKE_CXX_FLAGS} -fPIC -O2"
    "CPPFLAGS=-isystem ${CMAKE_INSTALL_PREFIX}/include"
    "LDFLAGS=-L${CMAKE_INSTALL_PREFIX}/lib -L${CMAKE_INSTALL_PREFIX}/lib64"
)

if (WITH_PIC)
    set(common_cmake_args "${common_cmake_args} -DCMAKE_CXX_FLAGS=-fPIC")
endif()

ExternalProject_Add(
    googletest
    URL https://github.com/google/googletest/archive/release-1.8.0.tar.gz
    URL_HASH MD5=16877098823401d1bf2ed7891d7dce36
    DOWNLOAD_NAME  googletest-1.8.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/googletest
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    BUILD_IN_SOURCE 1
    CMAKE_ARGS
        ${common_cmake_args}
    LOG_BUILD 1
    LOG_INSTALL 1
)
add_dependencies(googletest rocksdb)

ExternalProject_Add(
    gflags
    URL https://github.com/gflags/gflags/archive/v2.2.1.tar.gz
    URL_HASH MD5=b98e772b4490c84fc5a87681973f75d1
    DOWNLOAD_NAME gflags-2.2.1.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gflags
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
    BUILD_IN_SOURCE 1
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    glog
    URL https://github.com/google/glog/archive/v0.3.5.tar.gz
    URL_HASH MD5=5df6d78b81e51b90ac0ecd7ed932b0d4
    DOWNLOAD_NAME glog-0.3.5.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/glog
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    CONFIGURE_COMMAND
        autoreconf -ivf &&
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared
                    --enable-static
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${NCPU} install
    LOG_BUILD 1
    LOG_INSTALL 1
)
add_dependencies(glog gflags)

ExternalProject_Add(
    libunwind
    URL https://github.com/libunwind/libunwind/releases/download/v1.2.1/libunwind-1.2.1.tar.gz
    URL_HASH MD5=06ba9e60d92fd6f55cd9dadb084df19e
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libunwind
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/libunwind/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/libunwind/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/libunwind/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared --enable-static
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    openssl
    URL https://github.com/openssl/openssl/archive/OpenSSL_1_1_1c.tar.gz
    URL_HASH MD5=e54191af2dbef5f172ca5b7ceea08307
    DOWNLOAD_NAME openssl-1.1.1c.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/openssl
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/openssl/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/openssl/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/openssl/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./config no-shared threads --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install_sw -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    mstch
    URL https://github.com/no1msd/mstch/archive/1.0.2.tar.gz
    URL_HASH MD5=306e7fead7480884f698ab47a6082e18
    DOWNLOAD_NAME mstch-1.0.2.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/mstch
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/mstch/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/mstch/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/mstch/source
    CMAKE_ARGS
        ${common_cmake_args}
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    boost
    URL https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz
    URL_HASH MD5=4850fceb3f2222ee011d4f3ea304d2cb
    DOWNLOAD_NAME boost-1.67.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/boost
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/source
    CONFIGURE_COMMAND ./bootstrap.sh --without-icu --without-libraries=python --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND ./b2 -d0 --prefix=${CMAKE_INSTALL_PREFIX} runtime-link=static install -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    LOG_BUILD 0
    LOG_INSTALL 0
)

set(FOLLYCXXFLAGS "-Wno-array-bounds -Wno-class-memaccess -fPIC -DPIC -DFOLLY_HAVE_MEMRCHR -Wno-noexcept-type -Wno-error=parentheses -Wno-error=shadow=compatible-local")
#set(FollyCXXFlags "-Wno-defaulted-function-deleted")
ExternalProject_Add(
    folly
    URL https://github.com/facebook/folly/archive/v2018.08.20.00.tar.gz
    URL_HASH MD5=1260231dd088526297ec52e3e12bf0ee
    DOWNLOAD_NAME folly-2018-08-20.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/folly
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/folly/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/folly/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/folly/source
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DFOLLY_CXX_FLAGS=-Wno-error
        -DCMAKE_EXE_LINKER_FLAGS=-latomic
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${NCPU} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
    LOG_MERGED_STDOUTERR TRUE
)
add_dependencies(folly glog gflags boost double-conversion libevent)

ExternalProject_Add(
    fatal
    URL https://github.com/facebook/fatal/archive/v2018.08.20.00.tar.gz
    URL_HASH MD5=b0887650f53ba8a73924351024f761ad
    DOWNLOAD_NAME fatal-2018-08-20.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/fatal
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/fatal/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/fatal/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/fatal/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND install -d ${CMAKE_INSTALL_PREFIX}/include
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND cp -r fatal ${CMAKE_INSTALL_PREFIX}/include
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
    LOG_MERGED_STDOUTERR TRUE
)

ExternalProject_Add(
    wangle
    URL https://github.com/facebook/wangle/archive/v2018.08.20.00.tar.gz
    URL_HASH MD5=b20856081c1d21c1a033f9ca161398c5
    DOWNLOAD_NAME wangle-2018-08-20.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/wangle
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/wangle/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/wangle/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/wangle/source
    CMAKE_ARGS
        ${common_cmake_args}
        -DBoost_NO_SYSTEM_PATHS=OFF
        -DBUILD_TESTS=OFF
        -D_OPENSSL_LIBDIR=${CMAKE_INSTALL_PREFIX}/lib64
        wangle
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${NCPU} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
    LOG_MERGED_STDOUTERR TRUE
)
add_dependencies(wangle folly glog gflags boost double-conversion openssl libevent)

ExternalProject_Add(
    proxygen
    URL https://github.com/facebook/proxygen/archive/v2018.08.20.00.tar.gz
    URL_HASH MD5=cc71ffdf502355b05451bcd81478f3d7
    DOWNLOAD_NAME proxygen-2018-08-20.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/proxygen
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/proxygen/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/proxygen/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/proxygen/source
    PATCH_COMMAND patch -p0 < ${CMAKE_SOURCE_DIR}/patches/proxygen-2018-08-20.patch
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${NCPU} -C proxygen
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${NCPU} install -C proxygen
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
    LOG_MERGED_STDOUTERR TRUE
)
add_dependencies(proxygen wangle folly glog gflags boost double-conversion openssl libevent libunwind gperf)
ExternalProject_Add_Step(proxygen mannual-configure
    DEPENDEES download update patch configure
    DEPENDERS build install
    COMMAND autoreconf -ivf
    COMMAND
        ${common_configure_envs}
        "LIBS=-lssl -lcrypto -ldl -lrt -lglog -lunwind"
        ${CMAKE_CURRENT_BINARY_DIR}/proxygen/source/proxygen/configure
            ${common_configure_args}
            --disable-shared
            --enable-static
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/proxygen/source/proxygen
)

ExternalProject_Add(
    fbthrift
    URL https://github.com/facebook/fbthrift/archive/v2018.08.20.00.tar.gz
    URL_HASH MD5=346627716bae0a4015f67ab33f255173
    DOWNLOAD_NAME fbthrift-2018-08-20.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/fbthrift
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/fbthrift/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/fbthrift/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/fbthrift/source
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/fbthrift-2018-08-20.patch
    CMAKE_COMMAND env PATH=${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH} cmake
    CMAKE_ARGS
        ${common_cmake_args}
        -D_OPENSSL_LIBDIR=${CMAKE_INSTALL_PREFIX}/lib64
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${NCPU} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
    LOG_MERGED_STDOUTERR TRUE
)
add_dependencies(fbthrift bison flex mstch wangle folly glog gflags boost double-conversion openssl libevent)

ExternalProject_Add(
    jemalloc
    URL https://github.com/jemalloc/jemalloc/releases/download/5.1.0/jemalloc-5.1.0.tar.bz2
    URL_HASH MD5=1f47a5aff2d323c317dfa4cf23be1ce4
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/jemalloc
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/jemalloc/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/jemalloc/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/jemalloc/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-stats --enable-prof
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install_bin install_include install_lib_static -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    bzip2
    URL https://nchc.dl.sourceforge.net/project/bzip2/bzip2-1.0.6.tar.gz
    URL_HASH MD5=00b516f4704d4a7cb50a1d97e6e8e15b
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bzip2
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

# TODO Upgrade to take advantage of optimization
# TODO Only static libs
ExternalProject_Add(
    zstd
    URL https://github.com/facebook/zstd/archive/v1.3.4.tar.gz
    URL_HASH MD5=10bf0353e3dedd8bae34a188c25d4261
    DOWNLOAD_NAME zstd-1.3.4.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zstd
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -e -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    zlib
    URL https://github.com/madler/zlib/archive/v1.2.11.tar.gz
    URL_HASH MD5=0095d2d2d1f3442ce1318336637b695f
    DOWNLOAD_NAME zlib-1.2.11.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zlib
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args} --static
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    snappy
    URL https://github.com/google/snappy/archive/1.1.7.tar.gz
    URL_HASH MD5=ee9086291c9ae8deb4dac5e0b85bf54a
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/snappy
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/snappy/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/snappy/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/snappy/source
    UPDATE_COMMAND ""
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DSNAPPY_BUILD_TESTS=OFF
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${NCPU}
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

set(ROCKSDB_CXX_FLAGS "-Wno-pessimizing-move -Wno-redundant-move -Wno-deprecated-copy -Wno-error=shadow -Wno-error=sign-compare")
ExternalProject_Add(
    rocksdb
    URL https://github.com/facebook/rocksdb/archive/v5.15.10.tar.gz
    URL_HASH MD5=5b1c1fa7ff4756218514205238d8900d
    DOWNLOAD_NAME rocksdb-5.15.10.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/rocksdb
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/source
    UPDATE_COMMAND ""
    CMAKE_ARGS
        ${common_cmake_args}
        -DPORTABLE=ON
        -DWITH_SNAPPY=ON
        -DWITH_ZSTD=OFF
        -DWITH_ZLIB=ON
        -DWITH_JEMALLOC=OFF
        -DWITH_GFLAGS=OFF
        -DWITH_TESTS=OFF
        -DWITH_TOOLS=OFF
        -DFAIL_ON_WARNINGS=OFF
        -DCMAKE_BUILD_TYPE=Release
#-DCMAKE_CXX_FLAGS:STRING=${ROCKSDB_CXX_FLAGS}
    PATCH_COMMAND patch CMakeLists.txt ${CMAKE_SOURCE_DIR}/patches/rocksdb-5.15.10.patch
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${NCPU} VERBOSE=1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)
add_dependencies(rocksdb snappy zlib)

ExternalProject_Add(
    double-conversion
    URL https://github.com/google/double-conversion/archive/v1.1.6.tar.gz
    URL_HASH MD5=94f9abc9b1367083cf3e4569886b4170
    DOWNLOAD_NAME double-conversion-1.1.6.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/double-conversion
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/double-conversion/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/double-conversion/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/double-conversion/source
    CMAKE_ARGS
        ${common_cmake_args}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${NCPU}
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    libevent
    URL https://github.com/libevent/libevent/releases/download/release-2.1.11-stable/libevent-2.1.11-stable.tar.gz
    URL_HASH MD5=7f35cfe69b82d879111ec0d7b7b1c531
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libevent
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/libevent/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/libevent/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/libevent/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared
                    --enable-static
                    --disable-samples
                    --disable-libevent-regress
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    flex
    URL https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
    URL_HASH MD5=2882e3179748cc9f9c23ec593d6adc8d
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/flex
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --enable-static --disable-shared
    BUILD_COMMAND make -s
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    gperf
    URL http://ftpmirror.gnu.org/gperf/gperf-3.1.tar.gz
    URL_HASH MD5=9e251c0a618ad0824b51117d5d9db87e
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gperf
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared --enable-static
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    gettext
    URL http://ftpmirror.gnu.org/gettext/gettext-0.19.8.1.tar.gz
    URL_HASH MD5=97e034cf8ce5ba73a28ff6c3c0638092
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gettext
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gettext/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gettext/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gettext/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared --enable-static
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    bison
    URL http://ftp.gnu.org/gnu/bison//bison-3.0.5.tar.gz
    URL_HASH MD5=41ad57813157b61bfa47e33067a9d6f0
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bison
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --quiet
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)

# TODO(dutor) To depend on `keyutils`
ExternalProject_Add(
    krb5
    URL https://kerberos.org/dist/krb5/1.16/krb5-1.16.1.tar.gz
    URL_HASH MD5=848e9b80d6aaaa798e3f3df24b83c407
#URL https://kerberos.org/dist/krb5/1.16/krb5-1.16.3.tar.gz
#URL_HASH MD5=65f5f695bd78ba6a64ac786f571047f4
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/krb5
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${NCPU} -C src
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU} -C src
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add_Step(krb5 mannual-configure
    DEPENDEES download update patch configure
    DEPENDERS build install
    COMMAND
        ${common_configure_envs}
        ./configure
            ${common_configure_args}
            --enable-static
            --disable-shared
            --disable-rpath
            --disable-aesni
            --disable-thread-support
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/krb5/source/src
)
