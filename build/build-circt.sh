#!/bin/bash

set -exo pipefail

ROOT=$PWD
VERSION=$1

BINUTILS_GCC_VERSION=10.3.0
CMAKE_EXTRA_ARGS=
LLVM_ENABLE_PROJECTS="mlir"
LLVM_ENABLE_RUNTIMES=""
LLVM_TARGETS_TO_BUILD="X86;RISCV"
BASENAME=circt
NINJA_TARGET=install
NINJA_TARGET_RUNTIMES=
TAG=

case $VERSION in
trunk)
    BRANCH=main
    URL=https://github.com/llvm/circt.git
    VERSION=trunk-$(date +%Y%m%d)
    ;;
esac

FULLNAME=${BASENAME}-${VERSION}
OUTPUT=$2/${FULLNAME}.tar.xz

# some builds checkout a tag instead of a branch
# these builds have a different prefix for ls-remote
REF=refs/heads/${BRANCH}
if [[ -n "${TAG}" ]]; then
    REF=refs/tags/${TAG}
fi

# determine build revision
LLVMORG_REVISION=$(git ls-remote "${URL}" "${REF}" | cut -f 1)
REVISION="circt-${LLVMORG_REVISION}-gcc-${BINUTILS_GCC_VERSION}"
LAST_REVISION="${3}"

echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

if [[ "${REVISION}" == "${LAST_REVISION}" ]]; then
    echo "ce-build-status:SKIPPED"
    exit
fi

# Grab CEs GCC for its binutils
mkdir -p /opt/compiler-explorer
pushd /opt/compiler-explorer
curl -sL https://s3.amazonaws.com/compiler-explorer/opt/gcc-${BINUTILS_GCC_VERSION}.tar.xz | tar Jxf -
popd

export CXX=/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/bin/g++
export CC=/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/bin/gcc
export LD_LIBRARY_PATH=/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/lib64

BUILD_DIR=${ROOT}/buildllvm
BUILD2_DIR=${ROOT}/buildcirct
STAGING_DIR=${ROOT}/staging
rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"

git clone --depth 1 --single-branch -b "${BRANCH}" "${URL}" "${ROOT}/circt"
cd ${ROOT}/circt

git submodule init
git submodule update

# Build LLVM

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake \
    -G "Ninja" "${ROOT}/circt/llvm/llvm" \
    -DLLVM_ENABLE_PROJECTS="${LLVM_ENABLE_PROJECTS}" \
    -DLLVM_ENABLE_RUNTIMES="${LLVM_ENABLE_RUNTIMES}" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${STAGING_DIR}" \
    -DLLVM_BINUTILS_INCDIR:PATH="/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${BINUTILS_GCC_VERSION}/plugin/include" \
    -DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS_TO_BUILD}" \
    -DLLVM_PARALLEL_LINK_JOBS=4 \
    ${CMAKE_EXTRA_ARGS}

ninja ${NINJA_TARGET}

# Build CIRCT

mkdir -p ${BUILD2_DIR}
cd ${BUILD2_DIR}
cmake \
    -G "Ninja" "${ROOT}/circt" \
    -DMLIR_DIR="${BUILD_DIR}/lib/cmake/mlir" \
    -DLLVM_DIR="${BUILD_DIR}/lib/cmake/llvm" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${STAGING_DIR}"

ninja ${NINJA_TARGET}

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" --transform "s,^./,./${FULLNAME}/," -C "${STAGING_DIR}" .

echo "ce-build-status:OK"
