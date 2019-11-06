cmake_minimum_required(VERSION 3.0.0)
project("Nebula Third Party")
include(ExternalProject)

ExternalProject_Add(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG release-1.8.0
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest-src
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/googletest-build
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    LOG_BUILD 0
    LOG_INSTALL 0
)

ExternalProject_Add(
    flex
    URL https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
    URL_HASH MD5=2882e3179748cc9f9c23ec593d6adc8d
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/flex-src
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/flex-src/configure --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make install
    LOG_BUILD 0
    LOG_INSTALL 0
)

ExternalProject_Add(
    bison
    URL http://ftpmirror.gnu.org/bison/bison-3.4.2.tar.gz
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/bison-src
    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bison-src/configure --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make install
    LOG_BUILD 0
    LOG_INSTALL 0
)
