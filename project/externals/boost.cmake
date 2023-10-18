# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name boost)
set(source_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/source)
execute_process(
    COMMAND
        ${CMAKE_CXX_COMPILER} -print-file-name=libstdc++.so
    OUTPUT_VARIABLE glibcxx_path
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if (NOT ${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "mips64")
    get_filename_component(glibcxx_dir ${glibcxx_path} DIRECTORY)
    set(BOOST_ENV_COMMAND
        "env"
        "LD_LIBRARY_PATH=${glibcxx_dir}"
    )
endif()

ExternalProject_Add(
    ${name}
    URL https://boostorg.jfrog.io/artifactory/main/release/1.81.0/source/boost_1_81_0.tar.gz
    URL_HASH MD5=4bf02e84afb56dfdccd1e6aec9911f4b
    DOWNLOAD_NAME boost-1.81.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${name}
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${source_dir}
    CONFIGURE_COMMAND
        ./bootstrap.sh
            --without-icu
            --with-libraries=context,thread,system,filesystem,graph,program_options,regex,iostreams,date_time,python
            --prefix=${CMAKE_INSTALL_PREFIX}
#--without-libraries=wave,nowide,chrono,atomic,fiber,type_erasure,exception,timer,contract,math,locale,json,test,stacktrace,mpi,log,graph,graph_parallel
    BUILD_COMMAND
        ${BOOST_ENV_COMMAND}
        ./b2 install
            -d0
            -j${BUILDING_JOBS_NUM}
            --prefix=${CMAKE_INSTALL_PREFIX}
            --disable-icu
            include=${CMAKE_INSTALL_PREFIX}/include
            linkflags=-L${CMAKE_INSTALL_PREFIX}/lib
            "cxxflags=-fPIC ${extra_cpp_flags}"
            runtime-link=shared
            link=shared
            variant=release
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND rm -rf ${CMAKE_INSTALL_PREFIX}/lib/cmake/boost* ${CMAKE_INSTALL_PREFIX}/lib/cmake/Boost*
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} setup-compiler
    DEPENDEES configure
    DEPENDERS build
    COMMAND
        echo "using gcc : : ${CMAKE_CXX_COMPILER} $<SEMICOLON>"
            > ${source_dir}/tools/build/src/user-config.jam
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_Step(${name} trim
    DEPENDEES install
    COMMAND
        rm -rf ${CMAKE_INSTALL_PREFIX}/include/boost/{wave,log,atomic,test,fusion,geometry,gil,phoenix,spirit,beast,asio,compute,polygon,proto,units,metaparse,qvm,vmd,xpressive}
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND ./b2 clean
    COMMAND rm -f ${BUILD_INFO_DIR}/${name}-build
    WORKING_DIRECTORY ${source_dir}
)

ExternalProject_Add_StepTargets(${name} clean)
