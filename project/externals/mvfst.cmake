# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name mvfst)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/facebook/mvfst/archive/refs/tags/v${fb_release_tag}.00.tar.gz
    URL_HASH MD5=e513ea3dd7252d16ba7dfbb2dae14f06
    DOWNLOAD_NAME mvfst-${fb_package_name_part}.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DBUILD_TESTS=OFF
        -DBoost_NO_BOOST_CMAKE=ON
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_BUILD_TYPE=Release
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} copy-headers
    DEPENDEES build
    DEPENDERS install
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/common
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/common/third-party
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/common/udpsocket
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/common/events
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/fizz/handshake
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/fizz/client/handshake
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/codec
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/state
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/api
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/logging
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/folly_utils
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/priority
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/congestion_control
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/handshake
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/datagram
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/observer
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/flowcontrol
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/loss
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/client
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/client/handshake
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/client/state
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/server
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/server/handshake
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/server/state
    COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/include/quic/server/async_tran
    COMMAND bash -c "cp ${source_dir}/quic/common/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/common/."
    COMMAND bash -c "cp ${source_dir}/quic/common/third-party/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/common/third-party/."
    COMMAND bash -c "cp ${source_dir}/quic/common/third-party/*.hpp ${CMAKE_INSTALL_PREFIX}/include/quic/common/third-party/."
    COMMAND bash -c "cp ${source_dir}/quic/common/udpsocket/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/common/udpsocket/."
    COMMAND bash -c "cp ${source_dir}/quic/common/events/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/common/events/."
    COMMAND bash -c "cp ${source_dir}/quic/fizz/handshake/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/fizz/handshake/."
    COMMAND bash -c "cp ${source_dir}/quic/fizz/client/handshake/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/fizz/client/handshake/."
    COMMAND bash -c "cp ${source_dir}/quic/codec/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/codec/."
    COMMAND bash -c "cp ${source_dir}/quic/state/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/state/."
    COMMAND bash -c "cp ${source_dir}/quic/api/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/api/."
    COMMAND bash -c "cp ${source_dir}/quic/logging/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/logging/."
    COMMAND bash -c "cp ${source_dir}/quic/folly_utils/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/folly_utils/."
    COMMAND bash -c "cp ${source_dir}/quic/priority/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/priority/."
    COMMAND bash -c "cp ${source_dir}/quic/congestion_control/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/congestion_control/."
    COMMAND bash -c "cp ${source_dir}/quic/handshake/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/handshake/."
    COMMAND bash -c "cp ${source_dir}/quic/datagram/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/datagram/."
    COMMAND bash -c "cp ${source_dir}/quic/observer/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/observer/."
    COMMAND bash -c "cp ${source_dir}/quic/flowcontrol/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/flowcontrol/."
    COMMAND bash -c "cp ${source_dir}/quic/loss/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/loss/."
    COMMAND bash -c "cp ${source_dir}/quic/client/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/client/."
    COMMAND bash -c "cp ${source_dir}/quic/client/handshake/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/client/handshake/."
    COMMAND bash -c "cp ${source_dir}/quic/client/state/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/client/state/."
    COMMAND bash -c "cp ${source_dir}/quic/server/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/server/."
    COMMAND bash -c "cp ${source_dir}/quic/server/handshake/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/server/handshake/."
    COMMAND bash -c "cp ${source_dir}/quic/server/state/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/server/state/."
    COMMAND bash -c "cp ${source_dir}/quic/server/async_tran/*.h ${CMAKE_INSTALL_PREFIX}/include/quic/server/async_tran/."
    WORKING_DIRECTORY <SOURCE_DIR>
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
