# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.

set(name fizz)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/facebookincubator/fizz/archive/v2021.03.01.00.tar.gz
    URL_HASH MD5=2956b71505d1102a5da3238fd32d67fd
    DOWNLOAD_NAME fizz-2021-03-01.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM} -C fizz
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install -C fizz
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} mannual-configure
    DEPENDEES download update patch
    DEPENDERS build
    COMMAND ${CMAKE_COMMAND}
        ${common_cmake_args}
        -DBUILD_TESTS=OFF
        -DBoost_NO_BOOST_CMAKE=ON
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_BUILD_TYPE=Release
        -D_OPENSSL_LIBDIR=${CMAKE_INSTALL_PREFIX}/lib64
        .
    WORKING_DIRECTORY <SOURCE_DIR>/fizz
)

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND make clean -j
    COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
    WORKING_DIRECTORY <SOURCE_DIR>/wangle
)

ExternalProject_Add_StepTargets(${name} clean)
