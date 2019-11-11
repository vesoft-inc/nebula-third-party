# TODO Upgrade to take advantage of optimization
set(MakeEnvs "env" "CFLAGS=-fPIC")
ExternalProject_Add(
    zstd
    URL https://github.com/facebook/zstd/archive/v1.3.4.tar.gz
    URL_HASH MD5=10bf0353e3dedd8bae34a188c25d4261
    DOWNLOAD_NAME zstd-1.3.4.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zstd
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/zstd/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND
        "${MakeEnvs}"
        make -e -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)
