set(ROCKSDB_CXX_FLAGS "-Wno-pessimizing-move -Wno-redundant-move -Wno-deprecated-copy -Wno-error=shadow -Wno-error=sign-compare")
ExternalProject_Add(
    rocksdb
    URL https://github.com/facebook/rocksdb/archive/v5.15.10.tar.gz
    URL_HASH MD5=5b1c1fa7ff4756218514205238d8900d
    DOWNLOAD_NAME rocksdb-5.15.10.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/rocksdb
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/rocksdb/source
    UPDATE_COMMAND ""
    CMAKE_ARGS
        ${common_cmake_args}
        -DPORTABLE=ON
        -DWITH_SNAPPY=ON
        -DWITH_ZSTD=ON
        -DWITH_ZLIB=ON
        -DWITH_JEMALLOC=OFF
        -DWITH_GFLAGS=OFF
        -DWITH_TESTS=OFF
        -DWITH_TOOLS=OFF
        -DFAIL_ON_WARNINGS=OFF
        -DCMAKE_BUILD_TYPE=Release
#-DCMAKE_CXX_FLAGS:STRING=${ROCKSDB_CXX_FLAGS}
    PATCH_COMMAND patch CMakeLists.txt ${CMAKE_SOURCE_DIR}/patches/rocksdb-5.15.10.patch
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM} VERBOSE=1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
)
