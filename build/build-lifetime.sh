#!/bin/bash

set -e

# Grab CE's GCC for its binutils
BINUTILS_GCC_VERSION=9.2.0
mkdir -p /opt/compiler-explorer
pushd /opt/compiler-explorer
curl -sL https://s3.amazonaws.com/compiler-explorer/opt/gcc-${BINUTILS_GCC_VERSION}.tar.xz | tar Jxf -
popd

ROOT=$(pwd)
TAG=trunk
VERSION=lifetime-trunk-$(date +%Y%m%d)

OUTPUT=/root/clang-${VERSION}.tar.xz
S3OUTPUT=""
if echo $2 | grep s3://; then
    S3OUTPUT=$2
else
    OUTPUT=${2-/root/clang-${VERSION}.tar.xz}
fi

STAGING_DIR=$(pwd)/staging
rm -rf ${STAGING_DIR}
mkdir -p ${STAGING_DIR}

git clone --depth 1 --single-branch -b lifetime https://github.com/mgehre/llvm-project

mkdir build
cd build
cmake -G "Ninja" ../llvm-project/llvm \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DLLVM_ENABLE_PROJECTS=clang \
    -DCMAKE_INSTALL_PREFIX:PATH=/root/staging \
    -DLLVM_BINUTILS_INCDIR:PATH=/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${BINUTILS_GCC_VERSION}/plugin/include/

ninja install

export XZ_DEFAULTS="-T 0"
tar Jcf ${OUTPUT} --transform "s,^./,./clang-${VERSION}/," -C ${STAGING_DIR} .

if [[ ! -z "${S3OUTPUT}" ]]; then
    s3cmd put --rr ${OUTPUT} ${S3OUTPUT}
fi
