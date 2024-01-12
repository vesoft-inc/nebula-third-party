# Copyright (c) 2024 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name c-ares)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/c-ares/c-ares/releases/download/cares-1_24_0/c-ares-1.24.0.tar.gz
    URL_HASH MD5=25b872ee1c3bee8ff5f49b5f31307002
    DOWNLOAD_NAME c-ares-1.24.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DCARES_SHARED=ON
        -DCARES_BUILD_TOOLS=OFF
        -DCARES_SYMBOL_HIDING=ON
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
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
