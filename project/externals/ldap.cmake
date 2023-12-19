# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name ldap)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.3.tgz
    URL_HASH MD5=6b7229396b335dd5ab2d24841d7f4b53
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
    ${common_configure_envs}
    ./configure
        ${common_configure_args}
        --enable-syslog
        --enable-modules=no
        --enable-shared=yes
        --enable-static=no
        --with-tls
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

# update before configure
# ExternalProject_Add_Step(${name} updateldconfig
# DEPENDEES download
# DEPENDERS configure
# COMMAND
# echo "${BERKELEYDB_LIB_DIR}"
# >> /etc/ld.so.conf
# COMMAND ldconfig -v
# WORKING_DIRECTORY ${source_dir}
# )
ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND make clean -j
    COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_StepTargets(${name} clean)
