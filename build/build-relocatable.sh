#!/bin/bash

set -ex

# Grab CE's GCC for its binutils
BINUTILS_GCC_VERSION=9.2.0
mkdir -p /opt/compiler-explorer
pushd /opt/compiler-explorer
curl -sL https://s3.amazonaws.com/compiler-explorer/opt/gcc-${BINUTILS_GCC_VERSION}.tar.xz | tar Jxf -
popd

ROOT=$(pwd)
TAG=trunk
VERSION=relocatable-trunk-$(date +%Y%m%d)

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

# Setup llvm-project checkout
git clone --depth 20 --single-branch -b trivially-relocatable https://github.com/Quuxplusone/llvm-project.git

# Print a git log for debugging purposes
(cd llvm-project && git log HEAD~10...HEAD --oneline)

# Setup build directory and build configuration
mkdir build
cd build
cmake -G "Ninja" ../llvm-project/llvm \
    -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/root/staging \
    -DLLVM_BINUTILS_INCDIR:PATH=/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${BINUTILS_GCC_VERSION}/plugin/include

# Build and install artifacts
ninja install

# Don't try to compress the binaries as they don't like it

export XZ_DEFAULTS="-T 0"
tar Jcf ${OUTPUT} --transform "s,^./,./clang-${VERSION}/," -C ${STAGING_DIR} .

if [[ ! -z "${S3OUTPUT}" ]]; then
    s3cmd put --rr ${OUTPUT} ${S3OUTPUT}
fi
