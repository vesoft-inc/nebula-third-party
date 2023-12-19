# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name rocksdb)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/facebook/rocksdb/archive/refs/tags/v7.8.3.tar.gz
    URL_HASH MD5=745d3b15e57e31670b5ea607c5bb82ff
    DOWNLOAD_NAME rocksdb-7.8.3.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-7.8.3.patch
    UPDATE_COMMAND ""
    CMAKE_ARGS
        ${common_cmake_args}
        -DPORTABLE=ON
        -DWITH_SNAPPY=ON
        -DWITH_ZSTD=ON
        -DWITH_ZLIB=ON
        -DWITH_LZ4=ON
        -DWITH_BZ2=ON
        -DWITH_JEMALLOC=OFF
        -DWITH_GFLAGS=OFF
        -DWITH_TESTS=OFF
        -DWITH_BENCHMARK_TOOLS=OFF
        -DWITH_TOOLS=OFF
        -DUSE_RTTI=ON
        -DFAIL_ON_WARNINGS=OFF
        -DCMAKE_BUILD_TYPE=Release
        "-DCMAKE_EXE_LINKER_FLAGS=${extra_lib_dirs} -lbz2 -lsnappy -lzstd"
        "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} -D NPERF_CONTEXT"
        "-DCMAKE_SHARED_LINKER_FLAGS=${extra_lib_dirs} -Wl,-rpath=\$ORIGIN:\$ORIGIN/../3rd"
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND ""
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} install-static
    DEPENDEES build
    DEPENDERS install
    ALWAYS false
    COMMAND
        make -s install -j${BUILDING_JOBS_NUM}
    COMMAND
        find ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR} -name "librocksdb.a" -delete
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND make clean -j
    COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_StepTargets(${name} clean)
