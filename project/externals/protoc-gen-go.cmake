# Copyright (c) 2024 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

set(name protoc-gen-go)
add_custom_target(${name} ALL
    COMMAND env GOBIN=${CMAKE_INSTALL_PREFIX}/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.32
    COMMENT "Performing ${name} build & install"
)
