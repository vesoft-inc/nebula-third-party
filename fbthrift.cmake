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
add_dependencies(fbthrift krb5 bison flex mstch zlib zstd wangle folly glog gflags boost double-conversion openssl libevent)
