# Copyright (c) 2024 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name grpc)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/grpc/grpc/archive/refs/tags/v1.81.1.tar.gz
    URL_HASH MD5=939012ba93545dd8e3055f05d83d7e14
    DOWNLOAD_NAME grpc-1.81.1.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-1.78.1.patch
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        "-D_gRPC_C_CXX_FLAGS=-Wno-error=incompatible-pointer-types"
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_CARES_PROVIDER=package
        -DgRPC_RE2_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
        -DgRPC_ABSL_PROVIDER=package
        -DgRPC_BUILD_TESTS=OFF
    BUILD_COMMAND env LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}:${CMAKE_INSTALL_PREFIX}/lib:${CMAKE_INSTALL_PREFIX}/lib64  make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} hide-upb
    DEPENDEES configure
    DEPENDERS build
    COMMAND mv ${CMAKE_INSTALL_PREFIX}/include/upb ${CMAKE_INSTALL_PREFIX}/include/_upb || true
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_Step(${name} restore-upb
    DEPENDEES build
    DEPENDERS install
    COMMAND mv ${CMAKE_INSTALL_PREFIX}/include/_upb ${CMAKE_INSTALL_PREFIX}/include/upb || true
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
