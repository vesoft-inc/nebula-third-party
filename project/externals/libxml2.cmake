# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name libxml2)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
set(version "2.13.4")

ExternalProject_Add(
    ${name}
    URL https://github.com/GNOME/libxml2/archive/refs/tags/v2.13.4.tar.gz
    URL_HASH MD5=69d7c63c7fe5858ba7a462f303939c4a
    DOWNLOAD_NAME libxml2-${version}.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DBUILD_SHARED_LIBS=OFF
        -DLIBXML2_WITH_ICONV=ON
        -DLIBXML2_WITH_LZMA=OFF
        -DLIBXML2_WITH_PYTHON=OFF
        -DLIBXML2_WITH_ZLIB=OFF
        -DLIBXML2_WITH_PROGRAMS=OFF
        -DLIBXML2_WITH_TESTS=OFF
        "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} ${extra_c_flags}"
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
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
