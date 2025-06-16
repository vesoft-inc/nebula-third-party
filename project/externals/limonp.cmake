# Copyright (c) 2025 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name limonp)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/yanyiwu/limonp/archive/refs/tags/v1.0.1.tar.gz
    URL_HASH MD5=33971c4d56440ac5be06fb00274350b6
    DOWNLOAD_NAME ${name}-1.0.1.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/include
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${source_dir}/include ${CMAKE_INSTALL_PREFIX}/include
    BUILD_IN_SOURCE 0
)

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_StepTargets(${name} clean)
