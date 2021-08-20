# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.

set(name ldap)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.4.49.tgz
    URL_HASH MD5=2a47a6bb4319357ea7b032c45283e79e
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
        ${common_configure_envs}
        "LIBS=${LIBS}"
        "CPPFLAGS=-isystem ${CMAKE_BERKELEYDB_INCLUDE_INSTALL_PREFIX} -I ${CMAKE_INSTALL_PREFIX}/include ${extra_cpp_flags}"
        "LDFLAGS=-L${CMAKE_BERKELEYDB_LIB_INSTALL_PREFIX} -L${CMAKE_INSTALL_PREFIX}/lib -L${CMAKE_INSTALL_PREFIX}/lib64 ${extra_link_libs}"
        ./configure ${common_configure_args}
                    --enable-syslog
                    --enable-modules
                    --with-tls
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

#update before configure
ExternalProject_Add_Step(${name} updateldconfig
    DEPENDEES download
    DEPENDERS configure
    COMMAND
        echo "${CMAKE_BERKELEYDB_LIB_INSTALL_PREFIX}"
            >> /etc/ld.so.conf
    COMMAND ldconfig -v
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

