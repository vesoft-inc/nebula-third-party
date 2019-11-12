ExternalProject_Add(
    lzma
    URL https://tukaani.org/xz/xz-5.2.4.tar.xz
    URL_HASH MD5=003e4d0b1b1899fc6e3000b24feddf7c
    DOWNLOAD_NAME lzma-5.2.4.tar.xz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/lzma
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/lzma/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared --enable-static
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)
