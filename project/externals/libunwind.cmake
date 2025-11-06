# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name libunwind)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/libunwind/libunwind/archive/refs/tags/v1.8.3.tar.gz
    URL_HASH MD5=3b5ed56237d7c6c38ed313a785c0d6b2
#    URL_HASH MD5=e9c7623da33b8c0edca300ad56f07c40
    DOWNLOAD_NAME libunwind-1.8.3.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
#                    --disable-tests
                    --disable-minidebuginfo
                    --enable-shared
                    --disable-static
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)


# Starting from v1.8.1, the source code package does not include the configure command,
# so we need to rerun autoconfig before we can run configure
ExternalProject_Add_Step(${name} pre-configure
    DEPENDEES patch
    DEPENDERS configure
    ALWAYS FALSE
    COMMAND
        autoreconf -ivf
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
