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
