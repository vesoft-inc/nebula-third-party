# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

# TODO Upgrade to take advantage of optimization
set(name zstd)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
set(MakeEnvs "env" "CFLAGS=-fPIC")
ExternalProject_Add(
    ${name}
    URL https://github.com/facebook/zstd/archive/refs/tags/v1.5.2.tar.gz
    URL_HASH MD5=6dc24b78e32e7c99f80c9441e40ff8bc
    DOWNLOAD_NAME zstd-1.5.2.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND
        "${MakeEnvs}"
        make -e -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND
      make -C lib
           -s install-pc install-shared install-includes
           -j${BUILDING_JOBS_NUM}
           PREFIX=${CMAKE_INSTALL_PREFIX}
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
