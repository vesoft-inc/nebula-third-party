ExternalProject_Add(
    googletest
    URL https://github.com/google/googletest/archive/release-1.8.0.tar.gz
    URL_HASH MD5=16877098823401d1bf2ed7891d7dce36
    DOWNLOAD_NAME  googletest-1.8.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/googletest
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    BUILD_IN_SOURCE 1
    CMAKE_ARGS
        ${common_cmake_args}
    LOG_BUILD 1
    LOG_INSTALL 1
)
