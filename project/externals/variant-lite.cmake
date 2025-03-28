# Copyright (c) 2025 vesoft inc. All rights reserved.
#
# This source code is licensed under BSL-1.0 License.

set(name variant-lite)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/martinmoene/variant-lite/archive/7e3bce818adb69bab27ccb982ea1b6779c2e379e.zip
    URL_HASH MD5=b127526ab077edd2ba1f16ff2cc426f2
    DOWNLOAD_NAME ${name}-master.zip
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DVARIANT_LITE_OPT_BUILD_TESTS=OFF
        -DVARIANT_LITE_OPT_BUILD_EXAMPLES=OFF
        -DVARIANT_LITE_OPT_SELECT_STD=ON
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
