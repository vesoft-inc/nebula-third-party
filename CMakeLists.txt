cmake_minimum_required(VERSION 3.0.0)
project("Nebula Third Party")
include(ExternalProject)

cmake_host_system_information(RESULT NCPU QUERY NUMBER_OF_PHYSICAL_CORES)
if (NOT NCPU OR NCPU EQUAL 0)
    set(NCPU 1)
endif()

message(STATUS "CXX: $ENV{CXX}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER}")

option(WITH_PIC "Whether to build PIC archive" OFF)

set(common_cmake_args
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} -fPIC"
    "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} -fPIC"
    -DCMAKE_INCLUDE_PATH=${CMAKE_INSTALL_PREFIX}/include
    -DCMAKE_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib
)

set(common_configure_args
    --prefix=${CMAKE_INSTALL_PREFIX}
)

set(common_configure_envs
    "env"
    "CC=${CMAKE_C_COMPILER}"
    "CXX=${CMAKE_CXX_COMPILER}"
    "CFLAGS=${CMAKE_C_FLAGS} -fPIC -O3"
    "CXXFLAGS=${CMAKE_CXX_FLAGS} -fPIC -O2"
    "CPPFLAGS=-isystem ${CMAKE_INSTALL_PREFIX}/include"
    "LDFLAGS=-L${CMAKE_INSTALL_PREFIX}/lib -L${CMAKE_INSTALL_PREFIX}/lib64"
)

if (WITH_PIC)
    set(common_cmake_args "${common_cmake_args} -DCMAKE_CXX_FLAGS=-fPIC")
endif()

set(ALL_TARGETS
    bison
    flex
    gperf
    gettext
    libunwind
    openssl
    libevent
    krb5
    jemalloc
    bzip2
    zstd
    zlib
    snappy
    mstch
    fatal
    double-conversion
    gflags
    googletest
    glog
    boost
    rocksdb
    folly
    wangle
    proxygen
    fbthrift
)

foreach(target ${ALL_TARGETS})
    include(${target}.cmake)
endforeach()


#add_custom_target(post-build)
