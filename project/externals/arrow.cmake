# Copyright (c) 2023 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.
# This source code is licensed under Apache 2.0 License.
if(DISTRO_NAME STREQUAL "CentOS Linux" AND DISTRO_VERSION_ID STREQUAL "7")
    set(USE_LLVM_CXX ON)
else()
    set(USE_LLVM_CXX OFF)
endif()

set(name arrow)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
set(ARROW_CMAKE_ARGS
        -DProtobuf_SOURCE=BUNDLED
        -DRE2_SOURCE=BUNDLED
        -DBoost_ROOT=${CMAKE_INSTALL_PREFIX}
        -DGTest_ROOT=${CMAKE_INSTALL_PREFIX}
        -DOPENSSL_ROOT_DIR=${CMAKE_INSTALL_PREFIX}
        -DLLVM_ROOT=${CMAKE_INSTALL_PREFIX}
        -Dutf8proc_ROOT=${CMAKE_INSTALL_PREFIX}
        -DARROW_IPC=ON
        -DARROW_JSON=ON
        -DARROW_COMPUTE=ON
        -DARROW_GANDIVA=ON
        -DARROW_TESTING=ON
        -DARROW_JEMALLOC=OFF
        -DARROW_BUILD_TESTS=OFF
        -DARROW_BUILD_BENCHMARKS=OFF
        -DARROW_BUILD_STATIC=OFF
        -DARROW_BUILD_SHARED=ON
        -DARROW_TEST_MEMCHECK=OFF
        -DARROW_PYTHON=OFF
        -DUSE_LLVM_CXX=${USE_LLVM_CXX}
        -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath=\$ORIGIN:\$ORIGIN/../3rd
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        )

ExternalProject_Add(
        ${name}
        URL https://github.com/apache/arrow/archive/refs/tags/apache-arrow-11.0.0.tar.gz
        URL_HASH MD5=c31335b6f5422a352e2aef5a7a469c91
        DOWNLOAD_NAME apache-arrow-11.0.0.tar.gz
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
        TMP_DIR ${BUILD_INFO_DIR}
        STAMP_DIR ${BUILD_INFO_DIR}
        DOWNLOAD_DIR ${DOWNLOAD_DIR}
        PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-11.0.0.patch
        CONFIGURE_COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}" ${ARROW_CMAKE_ARGS} ./cpp
        BUILD_COMMAND
        "${MakeEnvs}"
        make -e -s -j${BUILDING_JOBS_NUM}
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND make install
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
