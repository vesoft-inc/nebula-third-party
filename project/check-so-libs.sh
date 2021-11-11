#! /usr/bin/env bash

# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.

if (( $# < 1 )); then
  echo "Usage: $0 <install_dir>"
  exit 1
fi

install_dir=$1
so_in_lib=`find $install_dir/lib -name *.so`
so_in_lib64=`find $install_dir/lib64 -name *.so`

if [[ -n $so_in_lib ]]; then
  echo "==> ERROR: found shared libraries in $install_dir/lib"
  exit 1
fi

if [[ -n $so_in_lib64 ]]; then
  echo "==> ERROR: found shared libraries in $install_dir/lib64"
  exit 1
fi

exit 0
