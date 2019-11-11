ExternalProject_Add(
    libtool
    URL https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz
    URL_HASH MD5=1bfb9b923f2c1339b4d2ce1807064aa5
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libtool
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/libtool/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        "LIBS=${LIBS}"
        ./configure ${common_configure_args}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
)
