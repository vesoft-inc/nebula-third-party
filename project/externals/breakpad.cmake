# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.

set(name breakpad)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    GIT_REPOSITORY https://github.com/google/breakpad.git
    GIT_TAG 38ee0be4d1118c9d86c0ffab25c6c521ff99fdee  # As of 2021/11/11
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2021-11-11.patch
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --quiet
                    --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} post-download
    DEPENDEES download
    DEPENDERS update
    ALWAYS FALSE
    COMMAND
        git clone
            --depth 1
            https://chromium.googlesource.com/linux-syscall-support
            ${source_dir}/src/third_party/lss
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_Step(${name} pre-patch
    DEPENDEES update
    DEPENDERS patch
    COMMAND
        git checkout -- src/client/linux/handler/exception_handler.cc
    WORKING_DIRECTORY ${source_dir}
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

