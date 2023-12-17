# Copyright (c) 2023 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

# TODO Upgrade to take advantage of optimization

set(name duckdb)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
set(make_envs "env" "GEN=ninja")
ExternalProject_Add(
    ${name}
    URL https://github.com/duckdb/duckdb/archive/refs/tags/v0.6.1.tar.gz
    URL_HASH MD5=a1498ddceed95e448b9eb5a1f99fe467
    DOWNLOAD_NAME duckdb-0.6.1.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-0.6.1.patch
    CONFIGURE_COMMAND ""
    BUILD_COMMAND
        "${make_envs}"
        make -e -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} custom-install
    ALWAYS TRUE
    DEPENDEES build
    DEPENDERS install
    COMMAND python3 scripts/amalgamation.py --extended
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/duckdb
    COMMAND cp src/amalgamation/duckdb.hpp ${CMAKE_INSTALL_PREFIX}/include/duckdb/.
    COMMAND cp build/release/src/libduckdb_static.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/fmt/libduckdb_fmt.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/miniz/libduckdb_miniz.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/re2/libduckdb_re2.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/hyperloglog/libduckdb_hyperloglog.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/utf8proc/libduckdb_utf8proc.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/fastpforlib/libduckdb_fastpforlib.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/libpg_query/libduckdb_pg_query.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/fsst/libduckdb_fsst.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/third_party/mbedtls/libduckdb_mbedtls.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/extension/parquet/libparquet_extension.a ${CMAKE_INSTALL_PREFIX}/lib/
    COMMAND cp build/release/extension/jemalloc/libjemalloc_extension.a ${CMAKE_INSTALL_PREFIX}/lib/
    WORKING_DIRECTORY ${source_dir}
    LOG TRUE
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
