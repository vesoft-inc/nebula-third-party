ExternalProject_Add(
    boost
    URL https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz
    URL_HASH MD5=4850fceb3f2222ee011d4f3ea304d2cb
    DOWNLOAD_NAME boost-1.67.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/boost
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/source
    CONFIGURE_COMMAND ./bootstrap.sh --without-icu --without-libraries=python --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND ./b2 -d0 --prefix=${CMAKE_INSTALL_PREFIX} runtime-link=static install -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    LOG_BUILD 0
    LOG_INSTALL 0
)
