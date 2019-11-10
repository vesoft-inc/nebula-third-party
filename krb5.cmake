# TODO(dutor) To depend on `keyutils`
ExternalProject_Add(
    krb5
    URL https://kerberos.org/dist/krb5/1.16/krb5-1.16.1.tar.gz
    URL_HASH MD5=848e9b80d6aaaa798e3f3df24b83c407
#URL https://kerberos.org/dist/krb5/1.16/krb5-1.16.3.tar.gz
#URL_HASH MD5=65f5f695bd78ba6a64ac786f571047f4
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/krb5
    TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/build-meta
    STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/build-meta
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/krb5/source
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -s -j${NCPU} -C src
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install -j${NCPU} -C src
    LOG_BUILD 1
    LOG_INSTALL 1
)

ExternalProject_Add_Step(krb5 mannual-configure
    DEPENDEES download update patch configure
    DEPENDERS build install
    COMMAND
        ${common_configure_envs}
        ./configure
            ${common_configure_args}
            --enable-static
            --disable-shared
            --disable-rpath
            --disable-aesni
            --disable-thread-support
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/krb5/source/src
)
