# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name proxygen)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)

ExternalProject_Add(
    ${name}
    URL https://github.com/facebook/proxygen/archive/refs/tags/v2021.11.29.00.tar.gz
    URL_HASH MD5=cfcc495376ea4e966c3492344e5b906e
    DOWNLOAD_NAME proxygen-2021-11-29.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2021-11-29.patch
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
            ${common_cmake_args}
            -DBUILD_SHARED_LIBS=OFF
			-DBoost_NO_BOOST_CMAKE=ON
            -DCMAKE_BUILD_TYPE=Release
            -DBUILD_TESTS=OFF
            -DBUILD_SAMPLES=OFF
            "-DCMAKE_EXE_LINKER_FLAGS=-static-libstdc++ -static-libgcc -pthread"
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
