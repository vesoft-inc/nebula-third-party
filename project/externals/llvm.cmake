# Copyright (c) 2023 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name llvm)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
set(LLVM_ENV_COMMAND
    "env"
    "LD_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib:${CMAKE_INSTALL_PREFIX}/lib64:${BERKELEYDB_LIB_DIR}:$ENV{LD_LIBRARY_PATH}"
)

ExternalProject_Add(
        ${name}
        URL https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/llvm-project-15.0.7.src.tar.xz
        URL_HASH MD5=bac436dbd5d37e38d3da75b03629053c
        DOWNLOAD_NAME llvm-project-15.0.7.src.tar.xz
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
        TMP_DIR ${BUILD_INFO_DIR}
        STAMP_DIR ${BUILD_INFO_DIR}
        DOWNLOAD_DIR ${DOWNLOAD_DIR}
        CONFIGURE_COMMAND
        ${CMAKE_COMMAND} -S llvm -B build -G Ninja
                         -DCMAKE_BUILD_TYPE=Release
                         -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
                         -DLLVM_ENABLE_PROJECTS='clang'
                         -DLLVM_ENABLE_RUNTIMES='libcxx\\$<SEMICOLON>libcxxabi'
                         -DLLVM_ENABLE_RTTI=ON
                         -DLLVM_BUILD_LLVM_DYLIB=ON
                         -DLLVM_LINK_LLVM_DYLIB=ON
                         -DLLVM_INCLUDE_BENCHMARKS=OFF
                         -DLLVM_INCLUDE_EXAMPLES=OFF
                         -DLLVM_INCLUDE_TESTS=OFF
                         -DLLVM_PARALLEL_COMPILE_JOBS=${BUILDING_JOBS_NUM}
                         -DLLVM_PARALLEL_LINK_JOBS=${BUILDING_JOBS_NUM}

        BUILD_COMMAND ${LLVM_ENV_COMMAND} ninja -C build install
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND ""
        LOG_CONFIGURE TRUE
        LOG_BUILD TRUE
        LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} clean
        EXCLUDE_FROM_MAIN TRUE
        ALWAYS TRUE
        DEPENDEES configure
        COMMAND ninja clean -j
        COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
        WORKING_DIRECTORY ${source_dir}
        )

ExternalProject_Add_StepTargets(${name} clean)
