# Copyright (c) 2023 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.
# This source code is licensed under Apache 2.0 License.
set(name arrow)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/src)

if(DISTRO_NAME STREQUAL "CentOS Linux" AND DISTRO_VERSION_ID STREQUAL "7")
    set(USE_LLVM_CXX ON)
else()
    set(USE_LLVM_CXX OFF)
endif()

set(arrow_cmake_args
        ${common_cmake_args}
        -DProtobuf_SOURCE=SYSTEM
        -Dre2_SOURCE=SYSTEM
        -DBoost_ROOT=${CMAKE_INSTALL_PREFIX}
        -DGTest_ROOT=${CMAKE_INSTALL_PREFIX}
        -DOPENSSL_ROOT_DIR=${CMAKE_INSTALL_PREFIX}
        -DLLVM_ROOT=${CMAKE_INSTALL_PREFIX}
        -Dutf8proc_ROOT=${CMAKE_INSTALL_PREFIX}
        -DARROW_IPC=ON
        -DARROW_JSON=ON
        -DARROW_COMPUTE=ON
        -DARROW_GANDIVA=OFF
        -DARROW_TESTING=ON
        -DARROW_FILESYSTEM=ON
        -DARROW_HDFS=ON
        -DARROW_S3=ON
        -DARROW_AZURE=ON
        -DARROW_GCS=ON
        -DARROW_CSV=ON
        -DARROW_JEMALLOC=OFF
        -DARROW_BUILD_TESTS=OFF
        -DARROW_BUILD_BENCHMARKS=OFF
        -DARROW_BUILD_STATIC=OFF
        -DARROW_BUILD_SHARED=ON
        -DARROW_TEST_MEMCHECK=OFF
        -DARROW_PYTHON=OFF
        -DARROW_PARQUET=ON
        -DARROW_ORC=ON
        -DARROW_DATASET=ON
        -DUSE_LLVM_CXX=${USE_LLVM_CXX}
        -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath=\$ORIGIN:\$ORIGIN/../3rd
        "-DCMAKE_CXX_FLAGS=${default_cxx_flags} -fpermissive"
        "-DCMAKE_C_FLAGS=${default_c_flags}"
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        )

set(make_envs
    "env"
    CMAKE_INCLUDE_PATH=${CMAKE_INSTALL_PREFIX}/include
    "CMAKE_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib:${CMAKE_INSTALL_PREFIX}/lib64"
    )

ExternalProject_Add(
        ${name}
        URL https://github.com/apache/arrow/archive/refs/tags/apache-arrow-23.0.1.tar.gz
        URL_HASH MD5=ea64d1a1a12f5b6b674db59e2efb2260
        DOWNLOAD_NAME apache-arrow-23.0.1.tar.gz
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
        TMP_DIR ${BUILD_INFO_DIR}
        STAMP_DIR ${BUILD_INFO_DIR}
        DOWNLOAD_DIR ${DOWNLOAD_DIR}
        CONFIGURE_COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}" ${arrow_cmake_args} ./cpp
        BUILD_COMMAND "${make_envs}" make -e -s -j${BUILDING_JOBS_NUM}
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND make install
        LOG_CONFIGURE TRUE
        LOG_BUILD TRUE
        LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} post-install
        DEPENDEES install
        COMMAND cp ${source_dir}/arrow/cpp/src/arrow/util/counting_semaphore_internal.h ${CMAKE_INSTALL_PREFIX}/include/arrow/util/.
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
