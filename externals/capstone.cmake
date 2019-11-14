set(name capstone)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL https://github.com/aquynh/capstone/archive/4.0.1.tar.gz
#URL_HASH MD5=00b516f4704d4a7cb50a1d97e6e8e15b
    DOWNLOAD_NAME capstone-4.0.1.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
        -DCAPSTONE_X86_SUPPORT=ON
        -DCAPSTONE_ARM_SUPPORT=OFF
        -DCAPSTONE_ARM64_SUPPORT=OFF
        -DCAPSTONE_M680X_SUPPORT=OFF
        -DCAPSTONE_M68K_SUPPORT=OFF
        -DCAPSTONE_MIPS_SUPPORT=OFF
        -DCAPSTONE_MOS65XX_SUPPORT=OFF
        -DCAPSTONE_PPC_SUPPORT=OFF
        -DCAPSTONE_SPARC_SUPPORT=OFF
        -DCAPSTONE_SYSZ_SUPPORT=OFF
        -DCAPSTONE_XCORE_SUPPORT=OFF
        -DCAPSTONE_X86_TMS320C64X=OFF
        -DCAPSTONE_X86_M680X=OFF
        -DCAPSTONE_X86_EVM=OFF
        -DCAPSTONE_BUILD_DIET=OFF
        -DCAPSTONE_X86_REDUCE=OFF
        -DCAPSTONE_BUILD_TESTS=OFF
        -DCAPSTONE_BUILD_STATIC=ON
        -DCAPSTONE_BUILD_SHARED=OFF
        -DCMAKE_BUILD_TYPE=Release
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM}
    LOG_BUILD 1
    LOG_INSTALL 1
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
