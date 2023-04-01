# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

# Update the include in headers to reflect the header folder name change
set(headers_directory "${INSTALL_PREFIX}/include/rocksdb-cloud")

file(GLOB_RECURSE header_files
    LIST_DIRECTORIES false
    "${headers_directory}/*.h"
)
list(LENGTH header_files file_num)
message(STATUS "headers directory: ${headers_directory}")
#message(STATUS "header files: ${header_files}")
message(STATUS "header file num: ${file_num}")

foreach(header_file ${header_files})
	#    message(STATUS "header file: ${header_file}")
    
    file(READ ${header_file} contents)

    string(REPLACE "#include \"rocksdb" "#include \"rocksdb-cloud" new_contents "${contents}")

    file(WRITE ${header_file} "${new_contents}")
endforeach()
