# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name jemalloc)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)

if ("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "aarch64")
    # Set page size to 64KB
    set(page_size_opts "--with-lg-page=16")
endif()

ExternalProject_Add(
    ${name}
    URL https://github.com/jemalloc/jemalloc/archive/refs/tags/5.3.0.tar.gz
    URL_HASH MD5=594dd8e0a1e8c1ef8a1b210a1a5aff5b
    DOWNLOAD_NAME jemalloc-5.3.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./autogen.sh ${common_configure_args}
                    --enable-stats --enable-prof
                    --with-version=5.3.0-0-gdeadbeaf    # jemalloc relies on this option to set various version related macros
                    ${page_size_opts}
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install_bin install_include install_lib_shared -j${BUILDING_JOBS_NUM}
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
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
