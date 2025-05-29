# Copyright (c) 2025 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.
set(name liboauth2)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)

ExternalProject_Add(
    ${name}
    URL https://github.com/OpenIDC/liboauth2/releases/download/v2.1.0/liboauth2-2.1.0.tar.gz
    URL_HASH MD5=8b74e19a45594d0f0e9c60a457fb867b
    DOWNLOAD_NAME liboauth2-2.1.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --without-nginx
                    --without-apache
                    --without-memcache
                    --with-redis
                    --enable-shared
                    --disable-static
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
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
