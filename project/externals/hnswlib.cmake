set(name hnswlib)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
ExternalProject_Add(
    ${name}
    URL               https://github.com/nmslib/hnswlib/archive/refs/tags/v0.8.0.zip
    URL_HASH          MD5=7d162011152e7cb68dfee85f7347abda
    PREFIX            ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR           ${BUILD_INFO_DIR}
    STAMP_DIR         ${BUILD_INFO_DIR}
    DOWNLOAD_DIR      ${DOWNLOAD_DIR}
    SOURCE_DIR        ${source_dir}
    INSTALL_COMMAND   ${CMAKE_COMMAND} -E copy_directory ${source_dir}/hnswlib ${CMAKE_INSTALL_PREFIX}/include/hnswlib
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
