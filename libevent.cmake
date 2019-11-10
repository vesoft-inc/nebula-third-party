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
