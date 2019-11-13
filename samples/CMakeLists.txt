cmake_minimum_required(VERSION 3.10.0)

project("SampleProjectToUseNebulaThirdParty" CXX)

include(ExternalProject)

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
    UPDATE_COMMAND ""
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/third-party/install
    INSTALL_COMMAND ""
)

ExternalProject_Add_Step(third-party clean
    EXCLUDE_FROM_MAIN TRUE
    DEPENDEES configure
    COMMAND
        make clean -j
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/third-party/build/src/third-party-build/
)

ExternalProject_Add_StepTargets(third-party clean)

set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-undefined -static-libstdc++ -static-libgcc")

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
    -Wl,--no-whole-archive
    resolv
    pthread
    dl
)

add_dependencies(all-in-one third-party)
