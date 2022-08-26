# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name libev)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add_Git(
    ${name}
    GIT_REPOSITORY https://github.com/kindy/libev.git
    GIT_TAG 6701966dfd095a080ba0b7d77cf950168256b0d0  # 4.33
    ARCHIVE_FILE libev-4.33.tar.gz
    ARCHIVE_MD5 2e41cd6820cb602d3bcb45165f6a90df
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-4.33.patch
    CONFIGURE_COMMAND
        "env"
        "CC=${CMAKE_C_COMPILER}"
        "CFLAGS=${CMAKE_C_FLAGS} -fPIC -O2"
        "CPPFLAGS=-isystem ${CMAKE_INSTALL_PREFIX}/include"
        "PATH=${BUILDING_PATH}"
        ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                    --enable-static
                    --disable-shared
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

# Because we modify the file Makefile.am, we need to rerun autoconfig before
# we can run configure
ExternalProject_Add_Step(${name} pre-configure
    DEPENDEES patch
    DEPENDERS configure
    ALWAYS FALSE
    COMMAND
        autoreconf -ivf
    WORKING_DIRECTORY ${source_dir}
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
