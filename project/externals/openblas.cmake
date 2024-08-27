# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name openblas)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/OpenMathLib/OpenBLAS/archive/refs/tags/v0.3.27.tar.gz
    URL_HASH MD5=ef71c66ffeb1ab0f306a37de07d2667f
    DOWNLOAD_NAME openblas-0.3.27.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make NO_LAPACKE=1 NO_AFFINITY=1 NO_WARMUP=1 DYNAMIC_ARCH=1 DYNAMIC_OLDER=1 TARGET=GENERIC NUM_THREADS=64 
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make PREFIX=${CMAKE_INSTALL_PREFIX} install
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

