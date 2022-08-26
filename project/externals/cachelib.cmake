# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name cachelib)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)

ExternalProject_Add_Git(
    ${name}
    GIT_REPOSITORY https://github.com/facebook/CacheLib.git
    GIT_TAG 12822a2eddd04bb3e252f458b36ee0675a2d4643  # As of 2021/12/02
    GIT_SUBMODULES ""
    ARCHIVE_FILE cachelib-2021-12-02.tar.gz
    ARCHIVE_MD5 251194612eb8de3362cd089df975e45c
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2021-12-02.patch
    SOURCE_DIR ${source_dir}
    SOURCE_SUBDIR cachelib
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DBoost_USE_STATIC_RUNTIME=ON
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

