cmake_minimum_required(VERSION 3.10.0)

project("Nebula Third Party" C CXX)

set(CXX_STANDARD 14)
set(CXX_STANDARD_REQUIRED ON)

# Required CMake modules
include(ExternalProject)

# Get number of physical CPU cores and megabytes of available memory
cmake_host_system_information(RESULT num_cores QUERY NUMBER_OF_PHYSICAL_CORES)
cmake_host_system_information(RESULT available_memory_mb QUERY AVAILABLE_PHYSICAL_MEMORY)
message(STATUS "Number of online physcial CPU cores: ${num_cores}")
message(STATUS "Available physical memory: ${available_memory_mb} MB")

# Guess the number of building jobs based on the available memories
set(jobs_by_cpu ${num_cores})
math(EXPR jobs_by_mem "${available_memory_mb} / 1024 / 2")
if (jobs_by_mem EQUAL 0)
    set(jobs_by_mem 1)
endif()

# Set the number of building jobs to min(jobs_by_mem, jobs_by_cpu),
# iff BUILDING_JOBS_NUM has not been set or set to 0.
if (NOT BUILDING_JOBS_NUM OR BUILDING_JOBS_NUM EQUAL 0)
    set(BUILDING_JOBS_NUM ${jobs_by_cpu})
    if (BUILDING_JOBS_NUM GREATER jobs_by_mem)
        set(BUILDING_JOBS_NUM ${jobs_by_mem})
    endif()
endif()

message(STATUS "Building Nebula Third Party with ${BUILDING_JOBS_NUM} jobs.")

option(WITH_PIC "Whether to build PIC archive" OFF)
set(DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/downloads)
set(BUILD_INFO_DIR ${CMAKE_CURRENT_BINARY_DIR}/build-info)
set(BUILDING_PATH "${CMAKE_INSTALL_PREFIX}/bin:${CMAKE_INSTALL_PREFIX}/sbin:$ENV{PATH}")
set(ACLOCAL_PATH "${CMAKE_INSTALL_PREFIX}/share/aclocal:${CMAKE_INSTALL_PREFIX}/share/aclocal-1.15")

message(STATUS "PATH while building: ${BUILDING_PATH}")

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
    --quiet
)

set(common_configure_envs
    "env"
    "CC=${CMAKE_C_COMPILER}"
    "CXX=${CMAKE_CXX_COMPILER}"
    "CFLAGS=${CMAKE_C_FLAGS} -fPIC -O2 -D_DEFAULT_SOURCE -D_GNU_SOURCE"
    "CXXFLAGS=${CMAKE_CXX_FLAGS} -fPIC -O2 -D_DEFAULT_SOURCE -D_GNU_SOURCE"
    "CPPFLAGS=-isystem ${CMAKE_INSTALL_PREFIX}/include"
    "LDFLAGS=-L${CMAKE_INSTALL_PREFIX}/lib -L${CMAKE_INSTALL_PREFIX}/lib64"
    "PATH=${BUILDING_PATH}"
    "ACLOCAL_PATH=${ACLOCAL_PATH}"
)

set(TOUCH_COMMAND ${CMAKE_SOURCE_DIR}/helpers/touch-if-exists.sh)

if (WITH_PIC)
    set(common_cmake_args "${common_cmake_args} -DCMAKE_CXX_FLAGS=-fPIC")
endif()

set(ALL_TARGETS
    autoconf
    autoconf-archive
    automake
    libtool
#pkgconf
    bison
    flex
    gperf
    gettext
    libunwind
    openssl
    libevent
    keyutils
    krb5
    jemalloc
    bzip2
    zstd
    zlib
    snappy
    lzma
    libaio
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
    include(externals/${target}.cmake)
    list(APPEND CLEAN_TARGETS ${target}-clean)
endforeach()

add_dependencies(autoconf-archive autoconf)
add_dependencies(automake autoconf autoconf-archive)
add_dependencies(libtool automake)
#add_dependencies(pkgconf libtool)

add_dependencies(glog libtool)
add_dependencies(bison libtool)
add_dependencies(flex libtool)
add_dependencies(zlib libtool)
add_dependencies(gettext libtool)
add_dependencies(lzma gettext)
add_dependencies(libevent libtool)
add_dependencies(gperf libtool)

add_dependencies(boost zlib bzip2 lzma)

add_dependencies(glog gflags)

add_dependencies(krb5 keyutils openssl gettext)
add_dependencies(folly glog boost double-conversion openssl libevent lzma zstd snappy libunwind libaio)
add_dependencies(wangle folly)
add_dependencies(fbthrift folly krb5 bison flex mstch zlib zstd wangle fatal)
add_dependencies(proxygen wangle libunwind gperf)
add_dependencies(rocksdb snappy zlib zstd bzip2 lzma libunwind)

add_custom_command(
    TARGET zstd POST_BUILD
    COMMAND
        rm -rf ${CMAKE_INSTALL_PREFIX}/lib/libzstd.so*
)

add_custom_command(
    TARGET rocksdb POST_BUILD
    COMMAND
        rm -rf ${CMAKE_INSTALL_PREFIX}/lib64/librocksdb.so*
)

add_custom_target(
    clean-all
    DEPENDS ${CLEAN_TARGETS}
)
