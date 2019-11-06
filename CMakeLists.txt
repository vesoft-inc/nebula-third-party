cmake_minimum_required(VERSION 3.0.0)
project("Nebula Third Party")
include(ExternalProject)

ExternalProject_Add(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG release-1.8.0
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/googletest
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest/source
    DOWNLOAD_DIR ""
    BUILD_IN_SOURCE 1
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    flex
    URL https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
    URL_HASH MD5=2882e3179748cc9f9c23ec593d6adc8d
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/flex
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex/source
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/flex/source/configure --quiet --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add(
    bison
    URL http://ftpmirror.gnu.org/bison/bison-3.4.2.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bison
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison/source
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bison/source/configure --quiet --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -s
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install
    LOG_BUILD 1
    LOG_INSTALL 1
)
