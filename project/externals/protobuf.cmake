# Copyright (c) 2024 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name protobuf)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protobuf-25.1.tar.gz
    URL_HASH MD5=105105aae0153d60059e982ead4d1d94
    DOWNLOAD_NAME protobuf-25.1.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DCARES_SHARED=ON
        -Dprotobuf_BUILD_TESTS=OFF
        -Dprotobuf_BUILD_LIBPROTOC=ON
        -Dprotobuf_DISABLE_RTTI=OFF
        -Dprotobuf_BUILD_SHARED_LIBS=ON
        -Dprotobuf_WITH_ZLIB=ON
        -Dprotobuf_ABSL_PROVIDER=package
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
