# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name cachelib)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
set(version "20240621")

ExternalProject_Add(
    ${name}
    URL https://github.com/facebook/CacheLib/archive/refs/tags/v${fb_release_tag}.00.tar.gz
    URL_HASH MD5=4e99f64f93829b18d2b8afaad4f5ce2e
    DOWNLOAD_NAME cachelib-${fb_package_name_part}.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    SOURCE_SUBDIR cachelib
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DBoost_NO_BOOST_CMAKE=ON
        -DBUILD_TESTS=OFF
        "-DCMAKE_CXX_FLAGS=${default_cxx_flags} -Wno-error=deprecated-declarations"
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

