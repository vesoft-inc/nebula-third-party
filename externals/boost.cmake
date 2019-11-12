get_filename_component(compiler_path ${CMAKE_CXX_COMPILER} DIRECTORY)
ExternalProject_Add(
    boost
    URL https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz
    URL_HASH MD5=4850fceb3f2222ee011d4f3ea304d2cb
    DOWNLOAD_NAME boost-1.67.0.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/boost
    TMP_DIR ${BUILD_INFO_DIR}
    STAMP_DIR ${BUILD_INFO_DIR}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/source
    CONFIGURE_COMMAND ""
    CONFIGURE_COMMAND
        env PATH=${compiler_path}:${BUILDING_PATH}
        ./bootstrap.sh
            --without-icu
            --without-libraries=python,test,stacktrace,mpi,log,graph,graph_parallel
            --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND
        env PATH=${compiler_path}:${BUILDING_PATH}
        ./b2 install
            -d0
            -j${BUILDING_JOBS_NUM}
            --prefix=${CMAKE_INSTALL_PREFIX}
            --disable-icu
            include=${CMAKE_INSTALL_PREFIX}/include
            linkflags=-L${CMAKE_INSTALL_PREFIX}/lib
            cxxflags="-fPIC"
            runtime-link=static
            link=static
            variant=release
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    LOG_BUILD 0
    LOG_INSTALL 0
)
