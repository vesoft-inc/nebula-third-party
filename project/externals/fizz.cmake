# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name fizz)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/facebookincubator/fizz/archive/refs/tags/v2022.12.26.00.tar.gz
    URL_HASH MD5=74eeed172e4b5bb8d990828e9787527d
    DOWNLOAD_NAME fizz-2022-12-26.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    SOURCE_SUBDIR fizz
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2022-12-26.patch
    CMAKE_ARGS
        ${common_cmake_args}
        -DBUILD_TESTS=OFF
        -DBoost_NO_BOOST_CMAKE=ON
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath=\$ORIGIN:\$ORIGIN/../3rd
        -D_OPENSSL_LIBDIR=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
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
    WORKING_DIRECTORY <SOURCE_DIR>
)

ExternalProject_Add_StepTargets(${name} clean)
