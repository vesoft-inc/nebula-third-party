ExternalProject_Add(
    autoconf
    URL https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
    URL_HASH MD5=82d05e03b93e45f5a39b828dc9c6c29b
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/autoconf
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/autoconf/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        "LIBS=${LIBS}"
        ./configure ${common_configure_args}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
)
