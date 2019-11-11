ExternalProject_Add(
    double-conversion
    URL https://github.com/google/double-conversion/archive/v1.1.6.tar.gz
    URL_HASH MD5=94f9abc9b1367083cf3e4569886b4170
    DOWNLOAD_NAME double-conversion-1.1.6.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/double-conversion
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/double-conversion/source
    CMAKE_ARGS
        ${common_cmake_args}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
)
