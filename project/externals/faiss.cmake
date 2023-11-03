set(name faiss)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL               https://github.com/facebookresearch/faiss/archive/refs/tags/v1.7.4.tar.gz
    URL_HASH          MD5=e1f96b228ec6a0819bc65efb9d196ec6
    PREFIX            ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR           ${BUILD_INFO_DIR}
    STAMP_DIR         ${BUILD_INFO_DIR}
    DOWNLOAD_DIR      ${DOWNLOAD_DIR}
    SOURCE_DIR        ${source_dir}
    CMAKE_ARGS
        ${common_cmake_args}
	-DBUILD_SHARED_LIBS=OFF
	-DFAISS_ENABLE_GPU=OFF
    BUILD_COMMAND     make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE   1
    INSTALL_COMMAND   make -s -j${BUILDING_JOBS_NUM} install
    LOG_CONFIGURE     TRUE
    LOG_BUILD         TRUE
    LOG_INSTALL       TRUE
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

