#! /bin/bash

[[ $# -lt 2 ]] && echo "$0 <subdir> <files...>" && exit 1

CMD="ossutil64 -e ${OSS_ENDPOINT} -i ${OSS_ID} -k ${OSS_SECRET}"
OSS_BASE=oss://nebula-graph
OSS_SUBDIR=$1
shift

for file in $@
do
    ${CMD} -f cp ${file} ${OSS_BASE}/${OSS_SUBDIR}/$(basename ${file})
done
