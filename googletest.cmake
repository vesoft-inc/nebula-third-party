ExternalProject_Add(
    googletest
    URL https://github.com/google/googletest/archive/release-1.8.0.tar.gz
    URL_HASH MD5=16877098823401d1bf2ed7891d7dce36
    DOWNLOAD_NAME  googletest-1.8.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/googletest
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/source
    BUILD_IN_SOURCE 1
    CMAKE_ARGS
        ${common_cmake_args}
    LOG_BUILD 1
    LOG_INSTALL 1
)
