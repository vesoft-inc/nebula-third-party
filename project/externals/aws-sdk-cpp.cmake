# Copyright (c) 2022 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name aws-sdk-cpp)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)

ExternalProject_Add_Git(
    ${name}
    GIT_REPOSITORY https://github.com/aws/aws-sdk-cpp.git
    GIT_TAG f61fa33a65d4c37cc3f2069d558771b45196158c  # As of 2022/9/19
    #ARCHIVE_FILE aws-sdk-2022-9-19.tar.gz
    #ARCHIVE_MD5 bee5b1a24318547232be73dbf06dbcc3
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    #PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2022-9-19.patch
SOURCE_DIR ${source_dir}
LIST_SEPARATOR "|"
CMAKE_ARGS
        ${common_cmake_args}
        -DENABLE_TESTING=OFF
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_BUILD_TYPE=Release
    -DBUILD_ONLY=s3|kinesis|transfer
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
