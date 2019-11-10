set(FOLLYCXXFLAGS "-Wno-array-bounds -Wno-class-memaccess -fPIC -DPIC -DFOLLY_HAVE_MEMRCHR -Wno-noexcept-type -Wno-error=parentheses -Wno-error=shadow=compatible-local")
#set(FollyCXXFlags "-Wno-defaulted-function-deleted")
ExternalProject_Add(
    folly
    URL https://github.com/facebook/folly/archive/v2018.08.20.00.tar.gz
    URL_HASH MD5=1260231dd088526297ec52e3e12bf0ee
    DOWNLOAD_NAME folly-2018-08-20.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/folly
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/folly/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/folly/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/folly/source
    CMAKE_ARGS
        ${common_cmake_args}
        -DCMAKE_BUILD_TYPE=Release
        -DFOLLY_CXX_FLAGS=-Wno-error
        -DCMAKE_EXE_LINKER_FLAGS=-latomic
    BUILD_COMMAND make -s -j${NCPU}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s -j${NCPU} install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
    LOG_MERGED_STDOUTERR TRUE
)
add_dependencies(folly glog gflags boost double-conversion libevent)
