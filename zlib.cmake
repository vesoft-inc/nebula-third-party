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
