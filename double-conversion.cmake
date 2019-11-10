ExternalProject_Add(
    double-conversion
    URL https://github.com/google/double-conversion/archive/v1.1.6.tar.gz
    URL_HASH MD5=94f9abc9b1367083cf3e4569886b4170
    DOWNLOAD_NAME double-conversion-1.1.6.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/double-conversion
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/double-conversion/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/double-conversion/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/double-conversion/source
    CMAKE_ARGS
        ${common_cmake_args}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${NCPU}
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)
