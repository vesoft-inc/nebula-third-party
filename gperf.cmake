ExternalProject_Add(
    gperf
    URL http://ftpmirror.gnu.org/gperf/gperf-3.1.tar.gz
    URL_HASH MD5=9e251c0a618ad0824b51117d5d9db87e
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gperf
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperf/source
    CONFIGURE_COMMAND
        ${common_configure_envs}
        ./configure ${common_configure_args}
                    --disable-shared --enable-static
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU}
    LOG_BUILD 1
    LOG_INSTALL 1
)
