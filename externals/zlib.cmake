ExternalProject_Add(
    zlib
    URL https://github.com/madler/zlib/archive/v1.2.11.tar.gz
    URL_HASH MD5=0095d2d2d1f3442ce1318336637b695f
    DOWNLOAD_NAME zlib-1.2.11.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zlib
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/source
    CONFIGURE_COMMAND
        "env"
        "CC=${CMAKE_C_COMPILER}"
        "CFLAGS=${CMAKE_C_FLAGS} -fPIC -O2"
        "CPPFLAGS=-isystem ${CMAKE_INSTALL_PREFIX}/include"
        "PATH=${BUILDING_PATH}"
        ./configure --prefix=${CMAKE_INSTALL_PREFIX} --static
    BUILD_COMMAND make -s -j${BUILDING_JOBS_NUM}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${BUILDING_JOBS_NUM} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)
