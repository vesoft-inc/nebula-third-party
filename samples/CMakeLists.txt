cmake_minimum_required(VERSION 3.10.0)

project("SampleProjectToUseNebulaThirdParty" CXX)

include(ExternalProject)

if(NOT THIRD_PARTY_DOWNLOAD_METHOD)
    set(THIRD_PARTY_DOWNLOAD_METHOD "URL")
endif()

if (${THIRD_PARTY_DOWNLOAD_METHOD} STREQUAL "URL")
    execute_process(
        COMMAND ${CMAKE_SOURCE_DIR}/helpers/retrieve-latest-release-tar.sh dutor nebula-third-party
        OUTPUT_VARIABLE TAR_URL
    )

    ExternalProject_Add(
        third-party
        URL ${TAR_URL}
        URL_HASH MD5=7929660c06effbf66bf04f18ac3dddbd
        DOWNLOAD_NAME nebula-third-party.tar.gz
        DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/third-party/downloads
        PREFIX ${CMAKE_BINARY_DIR}/third-party/build
        SOURCE_DIR ${CMAKE_BINARY_DIR}/third-party/source
        STAMP_DIR ${CMAKE_BINARY_DIR}/third-party/build-info
        TMP_DIR ${CMAKE_BINARY_DIR}/third-party/build-info
        BINARY_DIR ${CMAKE_BINARY_DIR}/third-party/build
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/third-party/install
        INSTALL_COMMAND ""
    )
elseif(${THIRD_PARTY_DOWNLOAD_METHOD STREQUAL "GIT")
    ExternalProject_Add(
        third-party
        GIT_REPOSITORY https://github.com/dutor/nebula-third-party.git
        GIT_TAG master
        GIT_SHALLOW TRUE
        GIT_PROGRESS TRUE
        PREFIX ${CMAKE_BINARY_DIR}/third-party/build
        SOURCE_DIR ${CMAKE_BINARY_DIR}/third-party/source
        STAMP_DIR ${CMAKE_BINARY_DIR}/third-party/build-info
        TMP_DIR ${CMAKE_BINARY_DIR}/third-party/build-info
        BINARY_DIR ${CMAKE_BINARY_DIR}/third-party/build
        UPDATE_COMMAND ""
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/third-party/install
        INSTALL_COMMAND ""
    )
endif()

ExternalProject_Add_Step(third-party clean
    EXCLUDE_FROM_MAIN TRUE
    DEPENDEES configure
    COMMAND
        make clean -j
    WORKING_DIRECTORY <BINARY_DIR>
)

ExternalProject_Add_StepTargets(third-party clean)

set(CMAKE_EXE_LINKER_FLAGS "-Wl,--no-undefined -static-libstdc++ -static-libgcc")

link_directories(
    ${CMAKE_BINARY_DIR}/third-party/install/lib
    ${CMAKE_BINARY_DIR}/third-party/install/lib64
)

add_executable(
    all-in-one
    all-in-one.cpp
)

target_include_directories(all-in-one SYSTEM PRIVATE ${CMAKE_BINARY_DIR}/third-party/install/include)

target_link_libraries(
    all-in-one
    -Wl,--whole-archive
    rocksdb
    folly
    follybenchmark
    event
    jemalloc
    double-conversion
    wangle
# proxygen
#   proxygenlib
#   proxygenhttpserver
#   fbthrift
    thrift
    thriftcpp2
    thriftprotocol
    protocol
    async
    transport
    concurrency
    security
    thriftfrozen2
    thrift-core
# boost
    boost_context
    boost_system
    boost_filesystem
    boost_program_options
    boost_thread
    boost_regex
# others
    krb5
    krb5support
    k5crypto
    gssapi_krb5
    com_err
    keyutils
    ssl
    crypto
    gtest
    gflags
    glog
    snappy
    z
    zstd
    bz2
    lzma
    unwind
    aio
    capstone
    -Wl,--no-whole-archive
    resolv
    pthread
    dl
)

add_dependencies(all-in-one third-party)

add_executable(elf-instrset elf-instrset.cpp)
target_compile_options(elf-instrset PRIVATE -g -O3)
add_dependencies(elf-instrset third-party)

target_include_directories(elf-instrset SYSTEM PRIVATE ${CMAKE_BINARY_DIR}/third-party/install/include)
target_link_libraries(elf-instrset capstone pthread dl)
