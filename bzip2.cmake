ExternalProject_Add(
    bzip2
    URL https://nchc.dl.sourceforge.net/project/bzip2/bzip2-1.0.6.tar.gz
    URL_HASH MD5=00b516f4704d4a7cb50a1d97e6e8e15b
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bzip2
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bzip2/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU} PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)
