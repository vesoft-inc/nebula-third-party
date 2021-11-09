# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.

set(name openssl)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
string(SUBSTRING "${CMAKE_HOST_SYSTEM_PROCESSOR}" 0 4 processor_prefix)

if (${processor_prefix} STREQUAL "mips")
    set(openssl_config_command
        "./Configure"
        "linux64-mips64"
    )
else()
    set(openssl_config_command "./config")
endif()
ExternalProject_Add(
    ${name}
    URL https://github.com/openssl/openssl/archive/OpenSSL_1_1_1j.tar.gz
    URL_HASH MD5=2913df113ecd2a396a171d9234556ea1
    DOWNLOAD_NAME openssl-1.1.1j.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ${openssl_config_command} no-shared threads --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install_sw -j${BUILDING_JOBS_NUM}
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
