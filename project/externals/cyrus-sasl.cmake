# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name cyrus-sasl)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/cyrusimap/cyrus-sasl/archive/refs/tags/cyrus-sasl-2.1.28.tar.gz
    URL_HASH MD5=7dcf3919b3085a1d09576438171bda91
    DOWNLOAD_NAME cyrus-sasl-2.1.28.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./autogen.sh ${common_configure_args}
                    --disable-static
                    --enable-shared
                    --disable-scram
                    --disable-digest
                    --disable-sample
                    --with-openssl=${CMAKE_INSTALL_PREFIX}
                    --with-bdb-incdir=${BERKELEYDB_INCLUDE_DIR}
                    --with-bdb-libdir=${BERKELEYDB_LIB_DIR}
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
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
