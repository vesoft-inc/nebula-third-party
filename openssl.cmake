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
