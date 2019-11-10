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
