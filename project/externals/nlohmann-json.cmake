# Copyright (c) 2025 vesoft inc. All rights reserved.
#
# This source code is licensed under MIT License.

set(name nlohmann-json)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/nlohmann/json/archive/3a5703931ad70852b668a46cac34354d1b264442.zip
    URL_HASH MD5=8c83312dd3fbf657e144be77799cfeba
    DOWNLOAD_NAME ${name}-develop-2025-03-29.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DNLOHMANN_JSON_CONFIG_INSTALL_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/nlohmann_json
        -DJSON_BuildTests=OFF
        -DJSON_Install=ON
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
