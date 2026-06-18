# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name wangle)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/facebook/wangle/archive/refs/tags/v${fb_release_tag}.00.tar.gz
    URL_HASH MD5=7e92b6f5440f9cccc07c48de053be952
    DOWNLOAD_NAME wangle-${fb_package_name_part}.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM} -C wangle
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install -C wangle
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} mannual-configure
    DEPENDEES download update patch
    DEPENDERS build
    COMMAND ${CMAKE_COMMAND}
        ${common_cmake_args}
        -DBoost_NO_SYSTEM_PATHS=OFF
        -DBoost_NO_BOOST_CMAKE=ON
        -DCMAKE_BUILD_TYPE=Release
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_EXE_LINKER_FLAGS=-latomic
        -DOPENSSL_ROOT_DIR=${CMAKE_INSTALL_PREFIX}
        .
    WORKING_DIRECTORY <SOURCE_DIR>/wangle
)

ExternalProject_Add_Step(${name} copy-headers
    DEPENDEES build
    DEPENDERS install
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/wangle/acceptor
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/wangle/ssl
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/wangle/bootstrap
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/wangle/channel
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/wangle/client/persistence
    COMMAND bash -c "cp ${source_dir}/wangle/acceptor/*.h ${CMAKE_INSTALL_PREFIX}/include/wangle/acceptor/."
    COMMAND bash -c "cp ${source_dir}/wangle/ssl/*.h ${CMAKE_INSTALL_PREFIX}/include/wangle/ssl/."
    COMMAND bash -c "cp ${source_dir}/wangle/bootstrap/*.h ${CMAKE_INSTALL_PREFIX}/include/wangle/bootstrap/."
    COMMAND bash -c "cp ${source_dir}/wangle/channel/*.h ${CMAKE_INSTALL_PREFIX}/include/wangle/channel/."
    COMMAND bash -c "cp ${source_dir}/wangle/client/persistence/*.h ${CMAKE_INSTALL_PREFIX}/include/wangle/client/persistence/."
    WORKING_DIRECTORY <SOURCE_DIR>
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
