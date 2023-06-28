#!/bin/bash

set -exo pipefail

ROOT=$PWD
VERSION=$1

BINUTILS_GCC_VERSION=9.2.0
declare -a CMAKE_EXTRA_ARGS
LLVM_ENABLE_PROJECTS="clang;"
LLVM_ENABLE_RUNTIMES="libcxx;libcxxabi"
LLVM_EXPERIMENTAL_TARGETS_TO_BUILD=
BASENAME=clang
NINJA_TARGET=install
NINJA_TARGET_RUNTIMES=install-runtimes
TAG=
PATCH_TO_APPLY=

case $VERSION in
ce-trunk)
    BRANCH=dbg-to-stdout
    URL=https://github.com/compiler-explorer/llvm-project.git
    VERSION=ce-trunk-$(date +%Y%m%d)
    ;;
autonsdmi-trunk)
    BRANCH=experiments
    URL=https://github.com/cor3ntin/llvm-project.git
    VERSION=autonsdmi-trunk-$(date +%Y%m%d)
    CMAKE_EXTRA_ARGS+=("-DLLVM_OPTIMIZED_TABLEGEN=ON")
    ;;
cppx-trunk)
    BRANCH=compiler-explorer
    URL=https://github.com/lock3/meta.git
    VERSION=cppx-trunk-$(date +%Y%m%d)
    ;;
cppx-p2320-trunk)
    BRANCH=paper/p2320
    URL=https://github.com/lock3/meta.git
    VERSION=cppx-p2320-trunk-$(date +%Y%m%d)
    ;;
cppx-ext-trunk)
    BRANCH=cppx
    URL=https://github.com/lock3/cppx.git
    VERSION=cppx-ext-trunk-$(date +%Y%m%d)
    ;;
p1061-trunk)
    BRANCH=ricejasonf/p1061
    URL=https://github.com/ricejasonf/llvm-project.git
    VERSION=p1061-trunk-$(date +%Y%m%d)
    ;;
embed-trunk)
    BRANCH=feature/embed
    URL=https://github.com/ThePhD/llvm-project.git
    VERSION=embed-trunk-$(date +%Y%m%d)
    ;;
dang-main)
    BRANCH=dang
    URL=https://github.com/ThePhD/llvm-project.git
    VERSION=dang-main-$(date +%Y%m%d)
    ;;
widberg-main)
    BRANCH=main
    URL=https://github.com/widberg/llvm-project-widberg-extensions.git
    VERSION=widberg-main-$(date +%Y%m%d)
    ;;
mizvekov-resugar)
    BRANCH=resugar
    URL=https://github.com/mizvekov/llvm-project.git
    VERSION=mizvekov-resugar-$(date +%Y%m%d)
    CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON")
    ;;
lifetime-trunk)
    BRANCH=lifetime
    URL=https://github.com/mgehre/llvm-project.git
    VERSION=lifetime-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES=""
    ;;
llvmflang-trunk)
    BRANCH=main
    URL=https://github.com/llvm/llvm-project.git
    VERSION=llvmflang-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_PROJECTS="mlir;flang;clang"
    LLVM_ENABLE_RUNTIMES=""
    NINJA_TARGET_RUNTIMES=
    # See https://github.com/compiler-explorer/clang-builder/issues/27
    CMAKE_EXTRA_ARGS+=("-DCMAKE_CXX_STANDARD=17" "-DLLVM_PARALLEL_COMPILE_JOBS=24")
    ;;
relocatable-trunk)
    BRANCH=trivially-relocatable
    URL=https://github.com/Quuxplusone/llvm-project.git
    VERSION=relocatable-trunk-$(date +%Y%m%d)
    ;;
patmat-trunk)
    BRANCH=llvmorg-master-pattern-matching
    URL=https://github.com/bcardosolopes/llvm-project.git
    VERSION=patmat-trunk-$(date +%Y%m%d)
    ;;
reflection-trunk)
    BRANCH=reflection
    URL=https://github.com/matus-chochlik/llvm-project.git
    VERSION=reflection-trunk-$(date +%Y%m%d)
    ;;
rocm-*)
    if [[ "${VERSION#rocm-}" == "trunk" ]]; then
        BRANCH=amd-stg-open
        ROCM_DEVICE_LIBS_BRANCH=${BRANCH}
        VERSION=rocm-trunk-$(date +%Y%m%d)
    else
        TAG=${VERSION}
        ROCM_DEVICE_LIBS_BRANCH=${VERSION}
    fi

    URL=https://github.com/RadeonOpenCompute/llvm-project.git
    ROCM_DEVICE_LIBS_URL=https://github.com/RadeonOpenCompute/ROCm-Device-Libs.git

    LLVM_ENABLE_PROJECTS="clang;lld;clang-tools-extra;compiler-rt"
    CMAKE_EXTRA_ARGS+=("-DLLVM_TARGETS_TO_BUILD=AMDGPU;X86")
    ;;
llvm-spirv)
    BASENAME=llvm-spirv
    BRANCH=main
    VERSION=trunk-$(date +%Y%m%d)
    URL=https://github.com/llvm/llvm-project.git

    SPIRV_LLVM_TRANSLATOR_URL=https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git
    CMAKE_EXTRA_ARGS+=("-DLLVM_SPIRV_INCLUDE_TESTS=OFF" "-DSPIRV_SKIP_CLANG_BUILD=ON" "-DSPIRV_SKIP_DEBUG_INFO_TESTS=ON")
    LLVM_ENABLE_PROJECTS=""
    LLVM_ENABLE_RUNTIMES=
    NINJA_TARGET=install-llvm-spirv
    NINJA_TARGET_RUNTIMES=
    ;;
llvm-*)
    BASENAME=llvm
    NINJA_TARGET=install-llvm-headers
    NINJA_TARGET_RUNTIMES=
    # strip prefix from front of version
    VERSION=${VERSION#llvm-}
    if [[ "${VERSION}" == "trunk" ]]; then
        BRANCH=main
        VERSION=trunk-$(date +%Y%m%d)
        CMAKE_EXTRA_ARGS+=("-DCLANG_ENABLE_HLSL=On")
        LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="DirectX;SPIRV"
    else
        TAG=llvmorg-${VERSION}
    fi
    URL=https://github.com/llvm/llvm-project.git
    ;;
mlir-*)
    BASENAME=mlir
    LLVM_ENABLE_PROJECTS="mlir"
    LLVM_ENABLE_RUNTIMES=
    NINJA_TARGET_RUNTIMES=

    VERSION=${VERSION#mlir-}
    if [[ "${VERSION}" == "trunk" ]]; then
        BRANCH=main
        VERSION=trunk-$(date +%Y%m%d)
    else
        TAG=llvmorg-${VERSION}
    fi
    URL=https://github.com/llvm/llvm-project.git
    ;;
*)
    case $VERSION in
    trunk)
        BRANCH=main
        VERSION=trunk-$(date +%Y%m%d)
        PATCH_TO_APPLY="${ROOT}/patches/ce-debug-clang-trunk.patch"
        ;;
    assertions-trunk)
        BRANCH=main
        VERSION=assertions-trunk-$(date +%Y%m%d)
        CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON")
        PATCH_TO_APPLY="${ROOT}/patches/ce-debug-clang-trunk.patch"
        ;;
    *)
        TAG=llvmorg-${VERSION}
        case $VERSION in
        "12.0.1" | "12.0.0")
            PATCH_TO_APPLY="${ROOT}/patches/ce-debug-clang-12.patch"
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="WebAssembly"
            ;;
        "11.0.1" | "11.0.0" | "10.0.1" | "10.0.0")
            PATCH_TO_APPLY="${ROOT}/patches/ce-debug-clang-11.patch"
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="WebAssembly"
            ;;
        *)
            PATCH_TO_APPLY="${ROOT}/patches/ce-debug-clang-trunk.patch"
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="M68k;WebAssembly"
            ;;
        esac
        ;;
    esac
    URL=https://github.com/llvm/llvm-project.git
    LLVM_ENABLE_PROJECTS="clang;lld;polly;clang-tools-extra"
    LLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;compiler-rt;openmp"
    ;;
esac

# use tag name as branch if otherwise unspecified
BRANCH=${BRANCH-$TAG}

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
REVISION="llvmorg-${LLVMORG_REVISION}-gcc-${BINUTILS_GCC_VERSION}"
LAST_REVISION="${3}"

echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

if [[ "${REVISION}" == "${LAST_REVISION}" ]]; then
    echo "ce-build-status:SKIPPED"
    exit
fi

# Grab CE's GCC for its binutils
mkdir -p /opt/compiler-explorer
pushd /opt/compiler-explorer
curl -sL https://s3.amazonaws.com/compiler-explorer/opt/gcc-${BINUTILS_GCC_VERSION}.tar.xz | tar Jxf -
popd

BUILD_DIR=${ROOT}/build
STAGING_DIR=${ROOT}/staging
rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"

# Setup llvm-project checkout
git clone --depth 1 --single-branch -b "${BRANCH}" "${URL}" "${ROOT}/llvm-project"

if [[ -n "${PATCH_TO_APPLY}" ]]; then
    cd "${ROOT}/llvm-project"
    git apply "${PATCH_TO_APPLY}" -v
    cd "${ROOT}"
fi

# For older LLVM versions, merge runtime and projects
# August 2021 is when bootstrapping become necessary, bootstrapping might have been supported previously a few years prior
COMMIT_DATE=$(cd "${ROOT}/llvm-project/llvm" && git show -s --format=%ct HEAD)
TIMESTAMP_BOOTSTRAP_NECESSARY=1627776000
if ((COMMIT_DATE < TIMESTAMP_BOOTSTRAP_NECESSARY)); then
    LLVM_ENABLE_PROJECTS="${LLVM_ENABLE_PROJECTS};${LLVM_ENABLE_RUNTIMES}"
    LLVM_ENABLE_RUNTIMES=
    NINJA_TARGET_RUNTIMES=
fi

if [[ -n "${SPIRV_LLVM_TRANSLATOR_URL}" ]]; then
    # Checkout SPIR-V/LLVM Translator
    git clone --depth 1 --single-branch -b "${BRANCH}" "${SPIRV_LLVM_TRANSLATOR_URL}" "${ROOT}/llvm-project/llvm/projects/SPIRV-LLVM-Translator"
fi

if [[ -n "${ROCM_DEVICE_LIBS_URL}" ]]; then
    # Checkout ROCm Device Libraries
    git clone --depth 1 --single-branch -b "${ROCM_DEVICE_LIBS_BRANCH}" "${ROCM_DEVICE_LIBS_URL}" "${ROOT}/llvm-project/llvm/projects/Device-Libs"
fi

# Setup build directory and build configuration
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake \
    -G "Ninja" "${ROOT}/llvm-project/llvm" \
    -DLLVM_ENABLE_PROJECTS="${LLVM_ENABLE_PROJECTS}" \
    -DLLVM_ENABLE_RUNTIMES="${LLVM_ENABLE_RUNTIMES}" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${STAGING_DIR}" \
    -DLLVM_BINUTILS_INCDIR:PATH="/opt/compiler-explorer/gcc-${BINUTILS_GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${BINUTILS_GCC_VERSION}/plugin/include" \
    -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="${LLVM_EXPERIMENTAL_TARGETS_TO_BUILD}" \
    -DLLVM_PARALLEL_LINK_JOBS=4 \
    "${CMAKE_EXTRA_ARGS[@]}"

# Build and install artifacts
ninja ${NINJA_TARGET}
if [[ -n "${NINJA_TARGET_RUNTIMES}" ]]; then
    ninja "${NINJA_TARGET_RUNTIMES}"
fi

# Don't try to compress the binaries as they don't like it

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" --transform "s,^./,./${FULLNAME}/," -C "${STAGING_DIR}" .


echo "ce-build-status:OK"
