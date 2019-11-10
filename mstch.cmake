ExternalProject_Add(
    mstch
    URL https://github.com/no1msd/mstch/archive/1.0.2.tar.gz
    URL_HASH MD5=306e7fead7480884f698ab47a6082e18
    DOWNLOAD_NAME mstch-1.0.2.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/mstch
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/mstch/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/mstch/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/mstch/source
    CMAKE_ARGS
        ${common_cmake_args}
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)
