cmake_minimum_required(VERSION 3.0.0)
project("Nebula Third Party")
include(ExternalProject)

cmake_host_system_information(RESULT ncpu QUERY NUMBER_OF_PHYSICAL_CORES)
if (NOT ncpu OR ncpu EQUAL 0)
    set(ncpu 1)
endif()

ExternalProject_Add(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG release-1.8.0
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/googletest
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/source
    UPDATE_COMMAND ""
    BUILD_IN_SOURCE 1
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    gflags
    GIT_REPOSITORY https://github.com/gflags/gflags.git
    GIT_TAG v2.2.1
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gflags
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/source
    UPDATE_COMMAND ""
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
    BUILD_IN_SOURCE 1
    LOG_BUILD 1
    LOG_INSTALL 1
)

# TODO Use built gflags
ExternalProject_Add(
    glog
    GIT_REPOSITORY https://github.com/google/glog.git
    GIT_TAG v0.3.5
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/glog
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/source
    UPDATE_COMMAND ""
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
    BUILD_IN_SOURCE 1
    LOG_BUILD 1
    LOG_INSTALL 1
)
add_dependencies(glog gflags)

ExternalProject_Add(
    libunwind
    GIT_REPOSITORY https://github.com/libunwind/libunwind.git
    GIT_TAG v1.2.1
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libunwind
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/libunwind/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/libunwind/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/libunwind/source
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libunwind/source/autogen.sh --quiet --disable-shared --enable-static --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu}
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
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/openssl/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/openssl/source
    CONFIGURE_COMMAND ./config no-shared threads --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install_sw -j${ncpu}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    jemalloc
    GIT_REPOSITORY https://github.com/jemalloc/jemalloc.git
    GIT_TAG 5.1.0
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/jemalloc
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/jemalloc/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/jemalloc/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/jemalloc/source
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/jemalloc/source/autogen.sh --quiet --prefix=${CMAKE_INSTALL_PREFIX} --enable-prof
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install_bin install_include install_lib_static -j${ncpu}
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
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

# TODO Upgrade to take advantage of optimization
# TODO Only static libs
ExternalProject_Add(
    zstd
    URL https://github.com/facebook/zstd/archive/v1.3.4.tar.gz
    URL_HASH MD5=10bf0353e3dedd8bae34a188c25d4261
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zstd
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -e -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    zlib
    URL https://github.com/madler/zlib/archive/v1.2.11.tar.gz
    URL_HASH MD5=0095d2d2d1f3442ce1318336637b695f
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zlib
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/source
    CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX} --static
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu} PREFIX=${CMAKE_INSTALL_PREFIX}
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
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/snappy/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/snappy/source
    UPDATE_COMMAND ""
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DSNAPPY_BUILD_TESTS=OFF
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${ncpu}
    INSTALL_COMMAND make -s install -j${ncpu}
    LOG_BUILD 1
    LOG_INSTALL 1
)

set(ROCKSDB_CXX_FLAGS "-Wno-pessimizing-move -Wno-redundant-move -Wno-deprecated-copy -Wno-error=shadow -Wno-error=sign-compare")
ExternalProject_Add(
    rocksdb
    URL https://github.com/facebook/rocksdb/archive/v5.15.10.tar.gz
    URL_HASH MD5=5b1c1fa7ff4756218514205238d8900d
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/rocksdb
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/source
    UPDATE_COMMAND ""
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DPORTABLE=ON -DWITH_TESTS=OFF -DWITH_GFLAGS=OFF -DWITH_JEMALLOC=OFF -DWITH_TOOLS=OFF -DCMAKE_CXX_FLAGS:STRING=${ROCKSDB_CXX_FLAGS}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${ncpu} VERBOSE=1
    INSTALL_COMMAND make -s install -j${ncpu}
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
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/libevent/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/libevent/source
    CONFIGURE_COMMAND ./configure --quiet --prefix=${CMAKE_INSTALL_PREFIX} --disable-shared --enable-static --disable-samples
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu}
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
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/source
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/flex/source/configure --quiet --enable-static --disable-shared --prefix=${CMAKE_INSTALL_PREFIX}
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
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/source
    CONFIGURE_COMMAND ./configure --quiet --prefix=${CMAKE_INSTALL_PREFIX} --disable-shared --enable-static
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu}
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
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/gettext/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gettext/source
    CONFIGURE_COMMAND ./configure --quiet --prefix=${CMAKE_INSTALL_PREFIX} --disable-shared --enable-static
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    bison
    URL http://ftpmirror.gnu.org/bison/bison-3.4.2.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bison
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/source
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bison/source/configure --quiet --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    krb5
    URL https://kerberos.org/dist/krb5/1.16/krb5-1.16.3.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/krb5
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/source
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/krb5/source/src/configure --quiet --enable-static --disable-shared --disable-rpath --disable-aesni --disable-thread-support --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${ncpu}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${ncpu}
    LOG_BUILD 1
    LOG_INSTALL 1
)
