# Copyright (c) 2025 vesoft inc. All rights reserved.
#
# This source code is licensed under BSL-1.0 License.

set(name string-view-lite)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/martinmoene/string-view-lite/archive/refs/tags/v1.8.0.tar.gz
    URL_HASH MD5=21c8279858fa8c65ff0ff8ff4033a2e4
    DOWNLOAD_NAME ${name}-1.8.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DSTRING_VIEW_LITE_OPT_BUILD_TESTS=OFF
        -DSTRING_VIEW_LITE_OPT_BUILD_EXAMPLES=OFF
        -DSTRING_VIEW_LITE_OPT_SELECT_STD=ON
        -DCMAKE_BUILD_TYPE=Release
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
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
