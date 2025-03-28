# Copyright (c) 2025 vesoft inc. All rights reserved.
#
# This source code is licensed under MPL-2.0 License.

set(name jinja2cpp)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/jinja2cpp/Jinja2Cpp/archive/refs/tags/1.3.2.tar.gz
    URL_HASH MD5=a046fd7575d1c6124b192af0e8185899
    DOWNLOAD_NAME ${name}-1.3.2.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DJINJA2CPP_WITH_JSON_BINDINGS=boost
        -DJINJA2CPP_DEPS_MODE=external
        -DJINJA2CPP_BUILD_TESTS=OFF
        -DJINJA2CPP_BUILD_SHARED=ON
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
