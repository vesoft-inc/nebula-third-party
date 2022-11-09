# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name rocksdb)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)

set(MakeEnvs "env" "EXTRA_CXXFLAGS=-I${CMAKE_INSTALL_PREFIX}/include" "USE_AWS=1" "USE_KAFKA=1" "PORTABLE=1" "WITH_SNAPPY=1"
    "WITH_ZSTD=1" "WITH_ZLIB=1" "WITH_LZ4=1" "WITH_BZ2=1" "WITH_JEMALLOC=0" "WITH_GFLAGS=0" "WITH_TESTS=0"
    "WITH_BENCHMARK_TOOLS=0" "WITH_TOOLS=0" "USE_RTTI=1" "FAIL_ON_WARNINGS=0" "WITH_AWS=1" "DISABLE_WARNING_AS_ERROR=0")

#do not set EXTRA_LDFLAGS

if(ENABLE_ROCKSDB_CLOUD)
    message(STATUS "use rocksdb cloud")
    ExternalProject_Add(
        ${name}
        GIT_REPOSITORY https://github.com/rockset/rocksdb-cloud.git
        GIT_TAG 956da0d46623d956670703a4af73b2526a5cd3cb  # As of 2022/9/19
        #ARCHIVE_FILE rocksdb-2022-9-19.tar.gz
        #ARCHIVE_MD5 89854dbe4a857068381b572081ab1e19
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
        TMP_DIR ${BUILD_INFO_DIR}
        STAMP_DIR ${BUILD_INFO_DIR}
        DOWNLOAD_DIR ${DOWNLOAD_DIR}
        #PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2022-9-19.patch
        SOURCE_DIR ${source_dir}
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ""
        BUILD_COMMAND
            "${MakeEnvs}"
            make static_lib -j${BUILDING_JOBS_NUM}
        INSTALL_COMMAND
            make install -j${BUILDING_JOBS_NUM} PREFIX=${CMAKE_INSTALL_PREFIX}
        LOG_CONFIGURE TRUE
        LOG_BUILD TRUE
        LOG_INSTALL TRUE
    )
else()
    message(STATUS "use rocksdb native")
    ExternalProject_Add(
        ${name}
        URL https://github.com/facebook/rocksdb/archive/refs/tags/v7.5.3.tar.gz
        URL_HASH MD5=5195c23691906f557aaa1827291196fd
        DOWNLOAD_NAME rocksdb-7.5.3.tar.gz
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
        TMP_DIR ${BUILD_INFO_DIR}
        STAMP_DIR ${BUILD_INFO_DIR}
        DOWNLOAD_DIR ${DOWNLOAD_DIR}
        SOURCE_DIR ${source_dir}
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
            "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} -D NPERF_CONTEXT"
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
        find ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR} -name "librocksdb.so*" -delete
    WORKING_DIRECTORY ${source_dir}
)
endif()

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND make clean -j
    COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_StepTargets(${name} clean)

