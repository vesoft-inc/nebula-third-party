ExternalProject_Add(
    wangle
    URL https://github.com/facebook/wangle/archive/v2018.08.20.00.tar.gz
    URL_HASH MD5=b20856081c1d21c1a033f9ca161398c5
    DOWNLOAD_NAME wangle-2018-08-20.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/wangle
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/wangle/source
    CMAKE_ARGS
        ${common_cmake_args}
        -DBoost_NO_SYSTEM_PATHS=OFF
        -DBUILD_TESTS=OFF
        -D_OPENSSL_LIBDIR=${CMAKE_INSTALL_PREFIX}/lib64
        wangle
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${BUILDING_JOBS_NUM} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
    LOG_MERGED_STDOUTERR TRUE
)
