ExternalProject_Add(
    bzip2
    URL https://nchc.dl.sourceforge.net/project/bzip2/bzip2-1.0.6.tar.gz
    URL_HASH MD5=00b516f4704d4a7cb50a1d97e6e8e15b
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bzip2
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make CFLAGS=-fPIC -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add_Step(bzip2 clean
    EXCLUDE_FROM_MAIN
    DEPENDEES configure
    COMMAND make clean -j
)

ExternalProject_Add_StepTargets(bzip2 clean)

#add_custom_command(
    #TARGET clean-bzip2
    #COMMAND make clean
    #WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bzip2/source
#)
