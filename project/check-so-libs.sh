#! /usr/bin/env bash

# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.

if (( $# < 1 )); then
  echo "Usage: $0 <install_dir>"
  exit 1
fi

install_dir=$1
if [ -e $install_dir/lib ]; then
  # llvm need generate some shared library for following reasons, do not check them here
  # 1. it generate libLTO.so libRemarks.so even configured build static library
  # 2. reduce binary size: tools configured to linked shared library: libclang.so, libLLVM.so
  so_in_lib=`find $install_dir/lib -name '*.so' | grep -v "libLTO.so\|libRemarks.so\|libclang\|libLLVM\|libc++"`
fi
if [ -e $install_dir/lib64 ]; then
  so_in_lib64=`find $install_dir/lib64 -name *.so`
fi

if [[ -n $so_in_lib ]]; then
  echo "==> ERROR: found shared libraries in $install_dir/lib"
  exit 1
fi

if [[ -n $so_in_lib64 ]]; then
  echo "==> ERROR: found shared libraries in $install_dir/lib64"
  exit 1
fi

exit 0
