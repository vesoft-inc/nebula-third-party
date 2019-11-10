ExternalProject_Add(
    glog
    URL https://github.com/google/glog/archive/v0.3.5.tar.gz
    URL_HASH MD5=5df6d78b81e51b90ac0ecd7ed932b0d4
    DOWNLOAD_NAME glog-0.3.5.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/glog
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/build-meta
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/glog/source
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    CONFIGURE_COMMAND
        autoreconf -ivf &&
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared
                    --enable-static
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${NCPU} install
    LOG_BUILD 1
    LOG_INSTALL 1
)
add_dependencies(glog gflags)
