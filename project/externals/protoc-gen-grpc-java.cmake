# Copyright (c) 2024 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name protoc-gen-grpc-java)
if ("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
    set(url "https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/1.60.0/protoc-gen-grpc-java-1.60.0-linux-x86_64.exe")
    set(url_hash 7542dc3182e089921eb5bd9cd254f9ff)
elseif("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "aarch64")
    set(url "https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/1.60.0/protoc-gen-grpc-java-1.60.0-linux-aarch_64.exe")
    set(url_hash 6fb580130536557efe766ccae12e56a7)
endif()
ExternalProject_Add(
    ${name}
    URL ${url}
    URL_HASH MD5=${url_hash}
    DOWNLOAD_NAME ${name}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    DOWNLOAD_NO_EXTRACT TRUE
    CONFIGURE_COMMAND ""
    BUILD_COMMAND chmod +x ${DOWNLOAD_DIR}/${name}
    INSTALL_COMMAND install -D ${DOWNLOAD_DIR}/${name} ${CMAKE_INSTALL_PREFIX}/bin/${name}
    BUILD_IN_SOURCE 1
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)
