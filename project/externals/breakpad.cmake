# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name breakpad)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)

# Function to get glibc version
function(glibc_version version)
    execute_process(
        COMMAND bash -c "ldd --version 2>&1 | head -n 1 | cut -d ')' -f 2"
        OUTPUT_VARIABLE GLIBC_VERSION
    )
    string(STRIP ${GLIBC_VERSION} GLIBC_VERSION)
    set(${version} ${GLIBC_VERSION} PARENT_SCOPE)
endfunction()

# Get the glibc version
glibc_version(GLIBC_VERSION)

set(patch_command "patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-2021-11-11.patch")

if("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "aarch64" AND ${GLIBC_VERSION} VERSION_LESS 2.20)
    string(APPEND patch_command " && patch -p1 < ${CMAKE_SOURCE_DIR}/patches/${name}-aarch64.patch")
endif()

ExternalProject_Add_Git(
    ${name}
    GIT_REPOSITORY https://github.com/google/breakpad.git
    GIT_TAG 38ee0be4d1118c9d86c0ffab25c6c521ff99fdee  # As of 2021/11/11
    ARCHIVE_FILE breakpad-2021-11-11.tar.gz
    ARCHIVE_MD5 0fba349ccf23a3f8b7de4a449de00f9f
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    PATCH_COMMAND bash -c "${patch_command}"
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --quiet
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

# The original repo for lss is https://chromium.googlesource.com/linux-syscall-support
# For the well-known reason, you cannot download it successfully every time. Because
# the code is not changing frequently, we pack it so that we don't have to download.
ExternalProject_Add_Step(${name} post-download
    DEPENDEES download
    DEPENDERS update
    ALWAYS FALSE
    COMMAND
        tar -C src/third_party/. -zxf ${CMAKE_SOURCE_DIR}/patches/lss-2021-12-20.tgz
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
