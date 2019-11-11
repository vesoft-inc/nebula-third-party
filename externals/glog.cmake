ExternalProject_Add(
    glog
    URL https://github.com/google/glog/archive/v0.3.5.tar.gz
    URL_HASH MD5=5df6d78b81e51b90ac0ecd7ed932b0d4
    DOWNLOAD_NAME glog-0.3.5.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/glog
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared
                    --enable-static
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add_Step(glog pre-configure
    DEPENDEES download update patch
    DEPENDERS configure
    COMMAND env PATH=${BUILDING_PATH} ACLOCAL_PATH=${ACLOCAL_PATH} autoreconf -if
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/glog/source
)
