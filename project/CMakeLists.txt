cmake_minimum_required(VERSION 3.23.1)  #Limited by faiss
if(POLICY CMP0114)
  cmake_policy(SET CMP0114 OLD)
endif()

# Not to pull submodules when an empty string is given
if(POLICY CMP0097)
    cmake_policy(SET CMP0097 NEW)
endif()

if(POLICY CMP0135) #Since cmake 3.24 it will make some download warning
    cmake_policy(SET CMP0135 OLD)
endif()

project("Nebula Third Party" C CXX)

set(CXX_STANDARD 17)
set(CXX_STANDARD_REQUIRED ON)

# Required CMake modules
include(ExternalProject)
include(CheckIncludeFileCXX)
include(cmake/ExternalProjectGit.cmake)

# Get number of physical CPU cores and megabytes of available memory
if ("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
    cmake_host_system_information(RESULT num_cores QUERY NUMBER_OF_PHYSICAL_CORES)
elseif ("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "aarch64" OR "${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "mips64")
    cmake_host_system_information(RESULT num_cores QUERY NUMBER_OF_LOGICAL_CORES)
endif()
cmake_host_system_information(RESULT available_memory_mb QUERY AVAILABLE_PHYSICAL_MEMORY)

execute_process(
    COMMAND ldd --version
    COMMAND head -1
    COMMAND cut -d ")" -f 2
    COMMAND cut -d " " -f 2
    OUTPUT_VARIABLE GLIBC_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

file(STRINGS /etc/os-release DISTRO_NAME REGEX "^NAME=")
file(STRINGS /etc/os-release DISTRO_VERSION_ID REGEX "^VERSION_ID=")
string(REGEX REPLACE "^NAME=\"(.*)\"$" "\\1" DISTRO_NAME ${DISTRO_NAME})
string(REGEX REPLACE "^VERSION_ID=\"(.*)\"$" "\\1" DISTRO_VERSION_ID ${DISTRO_VERSION_ID})

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

# BerkeleyDB dirs
set(BERKELEYDB_LIB_DIR ${CMAKE_INSTALL_PREFIX}/lib/berkeleydb-5.1.29)
set(BERKELEYDB_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include/berkeleydb-5.1.29)

message(STATUS "Number of online physcial CPU cores: ${num_cores}")
message(STATUS "Available physical memory: ${available_memory_mb} MB")
message(STATUS "Building third party with ${BUILDING_JOBS_NUM} jobs")
message(STATUS "Glibc version: ${GLIBC_VERSION}")
message(STATUS "Linux distribution name: ${DISTRO_NAME}")
message(STATUS "Linux distribution version ID: ${DISTRO_VERSION_ID}")

if (NOT DOWNLOAD_DIR)
    set(DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/tarballs)
endif()
set(BUILD_INFO_DIR ${CMAKE_CURRENT_BINARY_DIR}/build-info)
set(BUILDING_PATH "${CMAKE_INSTALL_PREFIX}/bin:${CMAKE_INSTALL_PREFIX}/sbin:$ENV{PATH}")
set(ACLOCAL_PATH "${CMAKE_INSTALL_PREFIX}/share/aclocal")

# the GCC of NeoKylin V5 on mips64 is provided by NeoKylin and needs to use the binutils of the GCC tool too
if (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "mips64")
    set(MIPS_LINK_FLAGS "-fuse-ld=bfd")
endif()

# Retrieve path and soname of libstdc++
execute_process(
    COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.so
    OUTPUT_VARIABLE libstdcxx_path
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND readelf -d ${libstdcxx_path}
    COMMAND grep SONAME
    COMMAND sed "s/.*\\[\\(.*\\)\\]/\\1/"
    OUTPUT_VARIABLE LIB_STDCXX_SONAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=${LIB_STDCXX_SONAME}
    OUTPUT_VARIABLE libstdcxx_path
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
get_filename_component(LIB_STDCXX_DIR ${libstdcxx_path} DIRECTORY CACHE)

# Retrieve path and soname of libgcc
execute_process(
    COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libgcc_s.so.1
    OUTPUT_VARIABLE libgcc_path
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND readelf -d ${libgcc_path}
    COMMAND grep SONAME
    COMMAND sed "s/.*\\[\\(.*\\)\\]/\\1/"
    OUTPUT_VARIABLE LIB_GCC_SONAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=${LIB_GCC_SONAME}
    OUTPUT_VARIABLE libgcc_path
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
get_filename_component(LIB_GCC_DIR ${libgcc_path} DIRECTORY CACHE)

message(STATUS "MIPS_LINK_FLAGS: ${MIPS_LINK_FLAGS}")

set(extra_lib_dirs "-L${CMAKE_INSTALL_PREFIX}/lib -L${CMAKE_INSTALL_PREFIX}/lib64")
set(extra_link_libs "${MIPS_LINK_FLAGS} ${extra_lib_dirs} -static-libstdc++ -static-libgcc -pthread -ldl")
if (${DISABLE_CXX11_ABI})
    set(extra_cpp_flags "-D_GLIBCXX_USE_CXX11_ABI=0")
else()
    set(extra_cpp_flags "-D_GLIBCXX_USE_CXX11_ABI=1")
endif()

set(ISA_FLAGS "")
if (NOT ${USE_ISA} STREQUAL "" AND NOT ${USE_ISA} STREQUAL "generic")
    set(ISA_FLAGS "-march=${USE_ISA}")
endif()

if(GLIBC_VERSION VERSION_LESS 2.17)
    set(extra_link_libs "${extra_link_libs} -lrt")
endif()

set(common_cmake_args
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
    "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -fPIC ${extra_cpp_flags} ${ISA_FLAGS}"
    "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} -fno-omit-frame-pointer -fPIC ${ISA_FLAGS}"
    "-DCMAKE_EXE_LINKER_FLAGS=${extra_link_libs} -Wl,-rpath=\$ORIGIN/../lib:\$ORIGIN/../lib64"
    -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath=\$ORIGIN:\$ORIGIN/../3rd:\$ORIGIN/../lib64:\$ORIGIN/../lib
    -DCMAKE_INCLUDE_PATH=${CMAKE_INSTALL_PREFIX}/include
    "-DCMAKE_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib:${CMAKE_INSTALL_PREFIX}/lib64"
    -DBUILD_SHARED_LIBS=ON
)

set(common_configure_args
    --prefix=${CMAKE_INSTALL_PREFIX}
)

set(ld_flags
    "-L${CMAKE_INSTALL_PREFIX}/lib"
    "-L${CMAKE_INSTALL_PREFIX}/lib64"
    "-L${BERKELEYDB_LIB_DIR}"
)
if (EXISTS "/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")
    set(ld_flags
        "${ld_flags}"
        "-L/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
    )
endif()
if (EXISTS "/usr/lib64/${CMAKE_LIBRARY_ARCHITECTURE}")
    set(ld_flags
        "${ld_flags}"
        "-L/usr/lib64/${CMAKE_LIBRARY_ARCHITECTURE}"
    )
endif()
set(ld_flags
    "${ld_flags}"
    "${extra_link_libs}"
)
string(JOIN " " ld_flags ${ld_flags})
set(common_configure_envs
    "env"
    "CC=${CMAKE_C_COMPILER}"
    "CXX=${CMAKE_CXX_COMPILER}"
    "CFLAGS=${CMAKE_C_FLAGS} -fcommon -fno-omit-frame-pointer -fPIC -O2 -D_DEFAULT_SOURCE -D_GNU_SOURCE ${extra_cpp_flags} ${ISA_FLAGS}"
    "CXXFLAGS=${CMAKE_CXX_FLAGS} -fcommon -fno-omit-frame-pointer -fPIC -O2 -D_DEFAULT_SOURCE -D_GNU_SOURCE ${extra_cpp_flags} ${ISA_FLAGS}"
    "CPPFLAGS=-isystem ${CMAKE_INSTALL_PREFIX}/include -I${BERKELEYDB_INCLUDE_DIR} ${extra_cpp_flags}"
    "LDFLAGS=-Wl,-rpath=\\\\$\\$ORIGIN ${ld_flags}"
    "LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:${CMAKE_INSTALL_PREFIX}/lib:${CMAKE_INSTALL_PREFIX}/lib64"
    "PATH=${BUILDING_PATH}"
    "ACLOCAL_PATH=${ACLOCAL_PATH}"
)

set(ALL_TARGETS
    abseil
    annoy
    arrow
    berkeleydb
    bison
    boost
    #breakpad
    bzip2
    #cachelib
    cppjieba
    cyrus-sasl
    c-ares
    datasketches
    date
    double-conversion
    duckdb
    eigen
    faiss
    fatal
    fizz
    flex
    fmt
    folly
    gflags
    glog
    googlebenchmark
    googletest
    gperf
    grpc
    hnswlib
    inja
    jemalloc
    jwt-cpp
    ldap
    libcurl
    libdwarf
    libev
    libevent
    libunwind
    libxml2
    limonp
    llvm
    lz4
    lzma
    mstch
    nlohmann-json
    openblas
    openssl
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    protoc-gen-grpc-java
    proxygen
    re2
    robin-hood-hashing
    rocksdb
    s2geometry
    simdjson
    snappy
    sodium
    sparsemap
    tomlplusplus
    utf8proc
    valijson
    wangle
    xsimd
    yaml-cpp
    zlib
    zstd
)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

CHECK_INCLUDE_FILE_CXX(elf.h ELF_INCLUDE_FOUND)
if (NOT ELF_INCLUDE_FOUND)
	message(FATAL_ERROR "Cannot find elf.h. Make sure you have it installed")
endif()

find_package(Libtool 2.4.2 QUIET)
if (NOT Libtool_FOUND)
    list(APPEND ALL_TARGETS libtool)
endif()

find_package(Autoconf 2.69 QUIET)
if (NOT Autoconf_FOUND)
    list(APPEND ALL_TARGETS autoconf)
endif()

find_package(AutoconfArchive QUIET)
if (NOT AutoconfArchive_FOUND)
    list(APPEND ALL_TARGETS autoconf-archive)
endif()

find_package(Automake 1.13.4 QUIET)
if (NOT Automake_FOUND)
    list(APPEND ALL_TARGETS automake)
endif()

find_package(Gettext QUIET)
if (NOT Gettext_FOUND)
    list(APPEND ALL_TARGETS gettext)
endif()

foreach(target ${ALL_TARGETS})
    include(externals/${target}.cmake)
    list(APPEND CLEAN_TARGETS ${target}-clean)
endforeach()

macro(maybe_add_dependencies depender)
    if (TARGET ${depender})
        foreach (dependee ${ARGN})
            if (TARGET ${dependee})
                add_dependencies(${depender} ${dependee})
            endif()
        endforeach()
    endif()
endmacro()

maybe_add_dependencies(autoconf-archive autoconf)
maybe_add_dependencies(automake autoconf autoconf-archive)
maybe_add_dependencies(libtool automake)

maybe_add_dependencies(glog libtool libunwind)
maybe_add_dependencies(gettext libtool)
maybe_add_dependencies(bison gettext libtool)
maybe_add_dependencies(flex libtool)
maybe_add_dependencies(zlib libtool)
maybe_add_dependencies(lzma gettext)
maybe_add_dependencies(libev gettext)
maybe_add_dependencies(libevent libtool openssl)
maybe_add_dependencies(libcurl libtool openssl)
# maybe_add_dependencies(date libcurl)
maybe_add_dependencies(gperf libtool)
maybe_add_dependencies(cyrus-sasl openssl berkeleydb automake libtool)
maybe_add_dependencies(ldap berkeleydb libtool openssl cyrus-sasl)

maybe_add_dependencies(boost zlib bzip2 lzma)
maybe_add_dependencies(mstch boost)

maybe_add_dependencies(glog gflags)

maybe_add_dependencies(googlebenchmark googletest)

maybe_add_dependencies(s2geometry googletest glog openssl abseil)

maybe_add_dependencies(folly glog boost double-conversion openssl libevent lzma zstd snappy lz4 libunwind fmt sodium jemalloc libdwarf)
maybe_add_dependencies(fizz folly)
maybe_add_dependencies(wangle folly fizz)
maybe_add_dependencies(proxygen wangle libunwind gperf)
maybe_add_dependencies(rocksdb snappy zlib zstd bzip2 lz4 lzma libunwind)
maybe_add_dependencies(cachelib fbthrift sparsemap fizz googletest)

# RocksDB has its own copy of gtest, which may conflict with ours
# Here we build gtest after rocksdb intentionally
maybe_add_dependencies(googletest rocksdb gflags)

maybe_add_dependencies(arrow openssl xsimd llvm boost jemalloc zstd utf8proc protobuf re2 libxml2 libcurl googletest)
maybe_add_dependencies(protobuf zlib abseil)
maybe_add_dependencies(re2 abseil)
maybe_add_dependencies(grpc protobuf re2 c-ares openssl)
maybe_add_dependencies(faiss openblas)

# JSON
maybe_add_dependencies(valijson nlohmann-json)
maybe_add_dependencies(inja nlohmann-json)

maybe_add_dependencies(jwt-cpp openssl)

maybe_add_dependencies(cppjieba limonp)

add_custom_target(
    clean-all
    DEPENDS ${CLEAN_TARGETS}
)

add_custom_target(
    pack-tarballs
    COMMAND
        tar czvf nebula-third-party-src-5.0.tgz tarballs
    COMMAND
        md5sum nebula-third-party-src-5.0.tgz
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/..
)
