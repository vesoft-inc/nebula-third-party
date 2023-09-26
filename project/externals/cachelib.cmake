# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name cachelib)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
set(version "2022.12.26")

ExternalProject_Add(
    ${name}
    URL http://github.com/facebook/cachelib/archive/refs/tags/v${version}.00.tar.gz
    URL_HASH MD5=6ff1cc495ab500d5b1053248f069a087
    DOWNLOAD_NAME cachelib-${version}.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    SOURCE_SUBDIR cachelib
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2022-12-26.patch
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DBoost_NO_BOOST_CMAKE=ON
        -DBUILD_TESTS=OFF
        "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} -Wno-error=deprecated-declarations ${extra_cpp_flags}"
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

