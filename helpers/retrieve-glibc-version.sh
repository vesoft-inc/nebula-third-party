#! /bin/bash

ldd --version | sed '1p' -n  | awk '{printf "%s",$NF}'
