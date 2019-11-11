ExternalProject_Add(
    mstch
    URL https://github.com/no1msd/mstch/archive/1.0.2.tar.gz
    URL_HASH MD5=306e7fead7480884f698ab47a6082e18
    DOWNLOAD_NAME mstch-1.0.2.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/mstch
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/mstch/source
    CMAKE_ARGS
        ${common_cmake_args}
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
)
