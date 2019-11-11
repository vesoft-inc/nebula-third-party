ExternalProject_Add(
    snappy
    URL https://github.com/google/snappy/archive/1.1.7.tar.gz
    URL_HASH MD5=ee9086291c9ae8deb4dac5e0b85bf54a
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/snappy
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/snappy/source
    UPDATE_COMMAND ""
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DSNAPPY_BUILD_TESTS=OFF
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
)
