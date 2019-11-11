ExternalProject_Add(
    gettext
    URL http://ftpmirror.gnu.org/gettext/gettext-0.19.8.1.tar.gz
    URL_HASH MD5=97e034cf8ce5ba73a28ff6c3c0638092
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gettext
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gettext/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared --enable-static
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
)
