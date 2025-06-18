# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name toml11)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/ToruNiina/toml11/archive/refs/tags/v4.4.0.tar.gz
    URL_HASH MD5=b576218153c21742e54920c061ff33cb
    DOWNLOAD_NAME toml11-4.4.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    UPDATE_COMMAND git submodule update --init --recursive
    CMAKE_ARGS
        ${common_cmake_args}
        -DTOML11_PRECOMPILE=ON
        -DCMAKE_CXX_STANDARD=17
        -B ${source_dir}/build
    BUILD_IN_SOURCE 1
    BUILD_COMMAND cmake --build . -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND cmake --install . --prefix ${CMAKE_INSTALL_PREFIX}
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
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${name}/src/${name}-build
)

ExternalProject_Add_StepTargets(${name} clean)
