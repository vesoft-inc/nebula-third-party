ExternalProject_Add(
    libaio
    URL https://github.com/crossbuild/libaio/archive/libaio-0.3.110-1.tar.gz
    URL_HASH MD5=266b58badf6d010eab433abc8713d959
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libaio
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/libaio/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND env CFLAGS=-fPIC make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make prefix=${CMAKE_INSTALL_PREFIX} -s install -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add_Step(libaio clean
    EXCLUDE_FROM_MAIN
    DEPENDEES configure
    COMMAND make clean -j
)

ExternalProject_Add_StepTargets(libaio clean)

add_custom_command(
    TARGET libaio POST_BUILD
    COMMAND
        rm -f ${CMAKE_INSTALL_PREFIX}/lib/libaio.so*
)
