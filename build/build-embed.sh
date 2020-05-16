#!/bin/bash

set -e

URL="https://github.com/ThePhD/llvm-project.git"
BRANCH="feature/embed"
BINUTILS_GCC_VERSION=9.2.0

if [[ "${BINUTILS_GCC_VERSION}" == "trunk" ]]; then
  BINUTILS_REVISION="$(git ls-remote --heads ${BINUTILS_GITURL} refs/heads/master | cut -f 1)"
else
  BINUTILS_REVISION="${BINUTILS_GCC_VERSION}"
fi

CLANG_REVISION=$(git ls-remote --heads ${URL} refs/heads/${BRANCH} | cut -f 1)
REVISION="clang-${CLANG_REVISION}-binutils-${BINUTILS_REVISION}"
LAST_REVISION="${3}"

echo "ce-build-revision:${REVISION}"

if [[ "${REVISION}" == "${LAST_REVISION}" ]]; then
  echo "ce-build-status:SKIPPED"
  exit
fi

# Grab CE's GCC for its binutils
mkdir -p /opt/compiler-explorer
pushd /opt/compiler-explorer
curl -sL https://s3.amazonaws.com/compiler-explorer/opt/gcc-${BINUTILS_GCC_VERSION}.tar.xz | tar Jxf -
popd

ROOT=$(pwd)
TAG=trunk
VERSION=embed-trunk-$(date +%Y%m%d)

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

git clone ${URL} -b ${BRANCH}


mkdir build
cd build
cmake -G "Ninja" ../llvm-project/llvm \
    -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/root/staging \
    -DLLVM_BINUTILS_INCDIR:PATH=/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${BINUTILS_GCC_VERSION}/plugin/include

ninja install

export XZ_DEFAULTS="-T 0"
tar Jcf ${OUTPUT} --transform "s,^./,./clang-${VERSION}/," -C ${STAGING_DIR} .

if [[ ! -z "${S3OUTPUT}" ]]; then
    s3cmd put --rr ${OUTPUT} ${S3OUTPUT}
fi
