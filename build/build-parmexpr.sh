#!/bin/bash

set -exo pipefail

# Grab CE's GCC for its binutils
BINUTILS_GCC_VERSION=9.2.0
mkdir -p /opt/compiler-explorer
pushd /opt/compiler-explorer
curl -sL https://s3.amazonaws.com/compiler-explorer/opt/gcc-${BINUTILS_GCC_VERSION}.tar.xz | tar Jxf -
popd

# Get CppDock and corresponding script to install the source files
curl -sL -o /bin/cppdock \
  https://raw.githubusercontent.com/ricejasonf/cppdock/e8d28cd8c630255bea7dd3912c13908c548145f0/cppdock
chmod a+x /bin/cppdock
curl -sL -o ./install_parmexpr_src.sh \
  https://raw.githubusercontent.com/ricejasonf/parametric_expressions/master/toolchain/install_src.sh

VERSION=parmexpr-trunk-$(date +%Y%m%d)

OUTPUT=/root/clang-${VERSION}.tar.xz
S3OUTPUT=""
if [[ $2 =~ ^s3:// ]]; then
    S3OUTPUT=$2
else
    if [[ -d "${2}" ]]; then
        OUTPUT=$2/${FULLNAME}.tar.xz
    else
        OUTPUT=${2-$OUTPUT}
    fi
fi

# determine build revision
PARMEXPR_VERSION=$(sha256sum ./install_parmexpr_src.sh | awk '{print $1}')
REVISION="parmexpr-${PARMEXPR_VERSION}-gcc-${BINUTILS_GCC_VERSION}"
LAST_REVISION="${3}"

echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

if [[ "${REVISION}" == "${LAST_REVISION}" ]]; then
    echo "ce-build-status:SKIPPED"
    exit
fi

STAGING_DIR=$(pwd)/staging
rm -rf ${STAGING_DIR}
mkdir -p ${STAGING_DIR}

source ./install_parmexpr_src.sh

mkdir build
cd build
cmake -G "Ninja" ../llvm \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/root/staging \
    -DLLVM_BINUTILS_INCDIR:PATH=/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${BINUTILS_GCC_VERSION}/plugin/include/

ninja install

export XZ_DEFAULTS="-T 0"
tar Jcf ${OUTPUT} --transform "s,^./,./clang-${VERSION}/," -C ${STAGING_DIR} .

if [[ ! -z "${S3OUTPUT}" ]]; then
    aws s3 cp --storage-class REDUCED_REDUNDANCY "${OUTPUT}" "${S3OUTPUT}"
fi

echo "ce-build-status:OK"
