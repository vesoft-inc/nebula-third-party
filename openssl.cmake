ExternalProject_Add(
    openssl
    URL https://github.com/openssl/openssl/archive/OpenSSL_1_1_1c.tar.gz
    URL_HASH MD5=e54191af2dbef5f172ca5b7ceea08307
    DOWNLOAD_NAME openssl-1.1.1c.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/openssl
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/openssl/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./config no-shared threads --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install_sw -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
)
