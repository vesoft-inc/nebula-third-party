# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name fmt)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/fmtlib/fmt/archive/refs/tags/9.1.0.tar.gz
    URL_HASH MD5=21fac48cae8f3b4a5783ae06b443973a
    DOWNLOAD_NAME fmt-9.1.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} mannual-configure
    DEPENDEES download update patch
    DEPENDERS build
    COMMAND ${CMAKE_COMMAND}
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DBUILD_TESTS=OFF
        -DFMT_TEST=OFF
        -DFMT_FUZZ=OFF
        -DFMT_INSTALL=ON
        .
    WORKING_DIRECTORY <SOURCE_DIR>
)

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND make clean -j
    COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
    WORKING_DIRECTORY <SOURCE_DIR>/wangle
)

ExternalProject_Add_StepTargets(${name} clean)
