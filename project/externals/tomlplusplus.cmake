# Copyright (c) 2025 vesoft inc. All rights reserved.
#
# This source code is licensed under MIT License.

set(name tomlplusplus)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/marzer/tomlplusplus/archive/708fff700f36ab3c2ab107b984ec9f3b8be5f055.zip
    URL_HASH MD5=98edb8b51728db283171e0da4481bfa2
    DOWNLOAD_NAME tomlplusplus-master.zip
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/include/toml++
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${source_dir}/include/toml++ ${CMAKE_INSTALL_PREFIX}/include/toml++
    BUILD_IN_SOURCE 1
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
