ExternalProject_Add(
    gflags
    URL https://github.com/gflags/gflags/archive/v2.2.1.tar.gz
    URL_HASH MD5=b98e772b4490c84fc5a87681973f75d1
    DOWNLOAD_NAME gflags-2.2.1.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gflags
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gflags/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
    BUILD_IN_SOURCE 1
    LOG_BUILD 1
    LOG_INSTALL 1
)
