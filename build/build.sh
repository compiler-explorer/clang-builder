#!/bin/bash

set -exo pipefail

ROOT=$PWD
VERSION=$1

GCC_VERSION=9.2.0
declare -a CMAKE_EXTRA_ARGS
declare -a NINJA_EXTRA_TARGETS
declare -a NINJA_EXTRA_TARGETS_NO_FAIL
LLVM_ENABLE_PROJECTS="clang"
LLVM_ENABLE_RUNTIMES="libcxx;libcxxabi"
LLVM_EXPERIMENTAL_TARGETS_TO_BUILD=
BASENAME=clang
NINJA_TARGET=install
NINJA_TARGET_RUNTIMES=install-runtimes
TAG=
declare -a COMMITS_TO_CHERRYPICK
declare -a PATCHES_TO_APPLY

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
    LLVM_ENABLE_RUNTIMES+=";libunwind"
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
    LLVM_ENABLE_RUNTIMES+=";libunwind"
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
    CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON" "-DLLVM_TARGETS_TO_BUILD=X86")
    LLVM_ENABLE_RUNTIMES+=";libunwind"
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
    # Does not compile with 9.2.0.
    GCC_VERSION=9.4.0
    BRANCH=main
    URL=https://github.com/llvm/llvm-project.git
    VERSION=llvmflang-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_PROJECTS="mlir;flang;clang"
    LLVM_ENABLE_RUNTIMES=""
    NINJA_TARGET_RUNTIMES=
    # See https://github.com/compiler-explorer/clang-builder/issues/27
    CMAKE_EXTRA_ARGS+=("-DCMAKE_CXX_STANDARD=17" "-DLLVM_PARALLEL_COMPILE_JOBS=12")
    ;;
relocatable-trunk)
    BRANCH=trivially-relocatable
    URL=https://github.com/Quuxplusone/llvm-project.git
    VERSION=relocatable-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_PROJECTS="clang"
    LLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi;libunwind"
    ;;
patmat-trunk)
    BRANCH=p2688-pattern-matching
    URL=https://github.com/mpark/llvm-project
    VERSION=patmat-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
clangir-trunk)
    # Does not compile with 9.2.0.
    GCC_VERSION=14.2.0
    BRANCH=main
    URL=https://github.com/llvm/clangir.git
    VERSION=clangir-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_PROJECTS="clang;mlir"
    LLVM_ENABLE_RUNTIMES="libunwind;libcxx;libcxxabi"
    CMAKE_EXTRA_ARGS+=( "-DCLANG_ENABLE_CIR=ON" "-DLLVM_ENABLE_ASSERTIONS=ON" "-DLLVM_TARGETS_TO_BUILD=X86;AArch64;ARM")
    ;;
reflection-trunk)
    BRANCH=reflection
    URL=https://github.com/matus-chochlik/llvm-project.git
    VERSION=reflection-trunk-$(date +%Y%m%d)
    ;;
variadic-friends-trunk)
    BRANCH=cxx-variadic-friends
    URL=https://github.com/dancrn/llvm-project.git
    VERSION=variadic-friends-trunk-$(date +%Y%m%d)
    ;;
bb-p2996-trunk)
    BRANCH=p2996
    URL=https://github.com/Bloomberg/clang-p2996
    VERSION=bb-p2996-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p2998-trunk)
    BRANCH=p2998
    URL=https://github.com/Bekenn/llvm-project
    VERSION=p2998-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p3068-trunk)
    BRANCH=P3068-constexpr-exceptions
    URL=https://github.com/hanickadot/llvm-project
    VERSION=p3068-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p3309-trunk)
    BRANCH=P3309-constexpr-atomic-and-atomic-ref
    URL=https://github.com/hanickadot/llvm-project
    VERSION=p3309-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p3367-trunk)
    BRANCH=P3367-constexpr-coroutines
    URL=https://github.com/hanickadot/llvm-project
    VERSION=p3367-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p3372-trunk)
    BRANCH=P3372-constexpr-containers-and-adaptors
    URL=https://github.com/hanickadot/llvm-project
    VERSION=p3372-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p3412-trunk)
    BRANCH=f-literals
    URL=https://github.com/BengtGustafsson/llvm-project-UTP.git
    VERSION=p3412-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
dascandy-contracts-trunk)
    BRANCH=add-contracts
    URL=https://github.com/dascandy/llvm-project
    VERSION=dascandy-contracts-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
ericwf-contracts-trunk)
    BRANCH=contracts-nightly
    URL=https://github.com/efcs/llvm-project
    VERSION=ericwf-contracts-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p1974-trunk)
    BRANCH=godbolt/propconst
    URL=https://github.com/je4d/llvm-project
    VERSION=p1974-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
chrisbazley-trunk)
    BRANCH=main
    URL=https://github.com/chrisbazley/llvm-project.git
    VERSION=chrisbazley-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
rocm-*)
    if [[ "${VERSION#rocm-}" == "trunk" ]]; then
        BRANCH=amd-staging
        VERSION=rocm-trunk-$(date +%Y%m%d)
        CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=1")
        ROCM_VERSION=999999 # trunk builds are "infinitely" far into the future
        LLVM_ENABLE_RUNTIMES+=";libunwind"
    else
        TAG=${VERSION}
        if [[ "${VERSION}" =~ rocm-([0-9]+)\.([0-9]+)\.[^.]+ ]]; then
            x=${BASH_REMATCH[1]}
            y=${BASH_REMATCH[2]}
            ROCM_VERSION=$(( x * 100 + y ))
        fi
    fi
    if (( ROCM_VERSION < 601 )); then
        ROCM_DEVICE_LIBS_BRANCH=${VERSION}
        ROCM_DEVICE_LIBS_URL=https://github.com/ROCm/ROCm-Device-Libs.git
    fi
    URL=https://github.com/ROCm/llvm-project.git
    LLVM_ENABLE_PROJECTS="clang;lld;clang-tools-extra;compiler-rt"
    CMAKE_EXTRA_ARGS+=("-DLLVM_TARGETS_TO_BUILD=AMDGPU;X86")
    ROCM_PATCH="${ROOT}/patches/ce-clang-${VERSION}.patch"
    if [[ -e "$ROCM_PATCH" ]]; then
        PATCHES_TO_APPLY+=("$ROCM_PATCH")
    fi
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
    NINJA_TARGET="install-llvm-headers install-llvm-libraries"
    NINJA_TARGET_RUNTIMES=
    # strip prefix from front of version
    VERSION=${VERSION#llvm-}
    if [[ "${VERSION}" == "trunk" ]]; then
        BRANCH=main
        VERSION=trunk-$(date +%Y%m%d)
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
    URL=https://github.com/llvm/llvm-project.git
    LLVM_ENABLE_PROJECTS="clang;lld;polly;clang-tools-extra"
    LLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;compiler-rt;openmp"

    case $VERSION in
    trunk)
        BRANCH=main
        VERSION=trunk-$(date +%Y%m%d)
        PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-trunk.patch")
        LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="DirectX;SPIRV;M68k"
        CMAKE_EXTRA_ARGS+=("-DCLANG_ENABLE_HLSL=On" "-DLIBCXX_INSTALL_MODULES=ON")
        LLVM_ENABLE_RUNTIMES+=";libunwind"
        ;;
    trunkaarch64)
        BRANCH=main
        VERSION=trunk-aarch64-$(date +%Y%m%d)
        PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-trunk.patch")
        LLVM_EXPERIMENTAL_TARGETS_TO_BUILD=""
        CMAKE_EXTRA_ARGS+=("-DLIBCXX_INSTALL_MODULES=ON -DLLVM_TARGETS_TO_BUILD=AArch64")
        LLVM_ENABLE_RUNTIMES+=";libunwind"
        ;;
    assertions-trunk)
        BRANCH=main
        VERSION=assertions-trunk-$(date +%Y%m%d)
        CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON" "-DLIBCXX_INSTALL_MODULES=ON")
        LLVM_ENABLE_RUNTIMES+=";libunwind"
        PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-trunk.patch")
        ;;
    *)
        # Handle assertions-{VERSION}
        PURE_VERSION=${VERSION#assertions-}
        if [[ $PURE_VERSION =~ ([0-9]+)\.([0-9]+)\.(.*) ]]; then
            MAJOR=${BASH_REMATCH[1]}
            MINOR=${BASH_REMATCH[2]}
        else
            echo "Unable to determine version of ${PURE_VERSION}"
            exit 1
        fi
        if [[ "${VERSION}" != "${PURE_VERSION}" ]]; then
            CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON")
            # NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang" "check-cxx")
        fi
        TAG=llvmorg-${PURE_VERSION}

        # Enable libunwind (useful for assertion builds but seemingly useful even if not)
        if [[ $MAJOR -lt 6 ]]; then
            # use older GCCs for 5 and earlier
            GCC_VERSION=5.5.0
            LLVM_ENABLE_PROJECTS+=";libunwind"
        else
            LLVM_ENABLE_RUNTIMES+=";libunwind"
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 5 ]]; then
            COMMITS_TO_CHERRYPICK+=("cf6b0c64b96cecaf961ef59f2b1db87f08f30881")
            COMMITS_TO_CHERRYPICK+=("f2f09fb32946a806f46285419fe6359f30206811") # present in 3.5.2
        fi

        if [[ ($MAJOR -eq 3 && $MINOR -le 5) || $MAJOR -lt 3 ]]; then
            GCC_VERSION=4.9.4
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 4 ]]; then
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-lld-3.4.patch")
        fi

        if [[ $MAJOR -eq 3 && ( $MINOR -eq 4 || $MINOR -eq 3 ) ]]; then
            CMAKE_EXTRA_ARGS+=("-DCMAKE_CXX_FLAGS=-std=c++0x")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 0 ]]; then
            COMMITS_TO_CHERRYPICK+=("00221ce63d450f9d024f437d7fb6bfa71b18f7a7")
        fi

        if [[ $MAJOR -eq 2 && $MINOR -eq 9 ]]; then
            GCC_VERSION=4.5.3
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check-all")
        fi
        
        if [[ $MAJOR -eq 2 && $MINOR -eq 8 ]]; then
            GCC_VERSION=4.5.3
            COMMITS_TO_CHERRYPICK+=("95b6f045f1f104b96d443c404755c2757b6f6cf7") # fix for clang++ symlink being absolute
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check" "clang-test" "clang-c++tests")
        fi

        if [[ $MAJOR -eq 2 && $MINOR -eq 7 ]]; then
            GCC_VERSION=4.4.7
            # COMMITS_TO_CHERRYPICK+=("95b6f045f1f104b96d443c404755c2757b6f6cf7") # fix for clang++ symlink being absolute
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-clang-2.7-clang-symlink.patch")
            # PATCHES_TO_APPLY+=("${ROOT}/patches/ce-clang-2.7-default-to-intel-asm-syntax.patch")
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check" "clang-test" "clang-c++tests")
        fi

        if [[ $MAJOR -eq 2 && $MINOR -eq 6 ]]; then
            GCC_VERSION=4.4.7
            COMMITS_TO_CHERRYPICK+=("ccc60da5c7bef1c454b27056dfb1b003ad71807e")
            NINJA_EXTRA_TARGETS_NO_FAIL+=("clang-test")
        fi

        # Patch debug output for clangs 10+
        if [[ $MAJOR -lt 10 ]]; then
            # version 9 don't have a patch for debug
            echo "Not patching for debug output"
        elif [[ $MAJOR -lt 12 ]]; then
            # versions 10 and 11
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-11.patch")
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="WebAssembly"
        elif [[ $MAJOR -eq 12 ]]; then
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-12.patch")
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="WebAssembly"
        else
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-trunk.patch")
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="M68k;WebAssembly"
        fi

        if [[ $MAJOR -ge 18 ]]; then
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_INSTALL_MODULES=ON")
        fi
        ;;
    esac
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
REVISION="llvmorg-${LLVMORG_REVISION}-gcc-${GCC_VERSION}"
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
curl -sL https://s3.amazonaws.com/compiler-explorer/opt/gcc-${GCC_VERSION}.tar.xz | tar Jxf -
popd

BUILD_DIR=${ROOT}/build
STAGING_DIR=${ROOT}/staging
rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"

# Setup llvm-project checkout
git clone --depth 1 --single-branch -b "${BRANCH}" "${URL}" "${ROOT}/llvm-project"

for COMMIT_TO_CHERRYPICK in "${COMMITS_TO_CHERRYPICK[@]}"; do
    git -C "${ROOT}/llvm-project" fetch --depth=10 origin "${COMMIT_TO_CHERRYPICK}" -v
    git -C "${ROOT}/llvm-project" cherry-pick -n "${COMMIT_TO_CHERRYPICK}" -v
done

for PATCH_TO_APPLY in "${PATCHES_TO_APPLY[@]}"; do
    git -C "${ROOT}/llvm-project" apply "${PATCH_TO_APPLY}" -v
done

# For older LLVM versions, merge runtime and projects
# August 2021 is when bootstrapping become necessary, bootstrapping might have been supported previously a few years prior
COMMIT_DATE=$(cd "${ROOT}/llvm-project/llvm" && git show -s --format=%ct HEAD)
TIMESTAMP_BOOTSTRAP_NECESSARY=1627776000
if ((COMMIT_DATE < TIMESTAMP_BOOTSTRAP_NECESSARY)); then
    LLVM_ENABLE_PROJECTS="${LLVM_ENABLE_PROJECTS};${LLVM_ENABLE_RUNTIMES}"
    LLVM_ENABLE_RUNTIMES=
    NINJA_TARGET_RUNTIMES=
fi

# Polly in LLVM 3.7 and on has libisl 0.15 checked out into the repository.
# Polly in LLVM 3.6 instead relies on `find_package(Isl REQUIRED)`, where `FindIsl.cmake` is provided by Polly.
# It searches for the library in the host system.
# Ubuntu 16.04 has libisl-dev 0.16 in the repositories, but it seems to be too new, because build fails.
# So we disable Polly for 3.6.
if [[ ($MAJOR -eq 3 && $MINOR -le 6) || $MAJOR -lt 3 ]]; then
    LLVM_ENABLE_PROJECTS="${LLVM_ENABLE_PROJECTS/polly/}"
fi

# LLVM 4.0 was the version where LLVM_ENABLE_PROJECTS was introduced.
# In older versions, users were supposed to clone subprojects into the right places,
# and LLVM's CMakeLists would pick them up if they are present.
# If they were not, they were silently ignored.
# The fact that all subprojects are in the git monorepo is an artifact of SVN to git migration.
# So, for older version we translate subprojects in LLVM_ENABLE_PROJECTS into symlinks
# right where old CMakeLists expect them to be.
if [[ $MAJOR -lt 5 ]]; then
    OIFS=$IFS
    IFS=";"
    for p in ${LLVM_ENABLE_PROJECTS}; do
        case $p in
        clang)
            ln -s "${ROOT}/llvm-project/clang" "${ROOT}/llvm-project/llvm/tools/clang" # Required for 3.9.0
            ;;
        clang-tools-extra)
            ln -s "${ROOT}/llvm-project/clang-tools-extra" "${ROOT}/llvm-project/clang/tools/extra" # Required for 3.9.0
            ;;
        compiler-rt)
            ln -s "${ROOT}/llvm-project/compiler-rt" "${ROOT}/llvm-project/llvm/projects/compiler-rt" # Required for 3.9.0
            ;;
        libcxx)
            if [[ ($MAJOR -eq 3 && $MINOR -ge 4) || $MAJOR -eq 4 ]]; then
                ln -s "${ROOT}/llvm-project/libcxx" "${ROOT}/llvm-project/llvm/projects/libcxx" # Required for 3.9.0
            fi
            # Skip libc++ 3.2. It assumes Clang, and we don't know how to build it even using period-correct Clang
            if [[ $MAJOR -eq 3 && $MINOR -eq 3 ]]; then
                rm -rf "${ROOT}/llvm-project/clang/runtime/libcxx"
                ln -s "${ROOT}/llvm-project/libcxx" "${ROOT}/llvm-project/clang/runtime/libcxx"
            fi
            ;;
        libcxxabi)
            ln -s "${ROOT}/llvm-project/libcxxabi" "${ROOT}/llvm-project/llvm/projects/libcxxabi" # Required for 4.0.0
            ;;
        libunwind)
            ln -s "${ROOT}/llvm-project/libunwind" "${ROOT}/llvm-project/llvm/projects/libunwind" # Required for 3.9.0
            ;;
        lld)
            ln -s "${ROOT}/llvm-project/lld" "${ROOT}/llvm-project/llvm/tools/lld" # Required for 3.9.0
            ;;
        polly)
            ln -s "${ROOT}/llvm-project/polly" "${ROOT}/llvm-project/llvm/tools/polly" # Required for 3.9.0
            ;;
        *)
            # openmp: CMake files of those old versions of LLVM doesn't seem to be aware of OpenMP runtime
            ;;
        esac
    done
    IFS=$OIFS
fi

if [[ -n "${SPIRV_LLVM_TRANSLATOR_URL}" ]]; then
    # Checkout SPIR-V/LLVM Translator
    git clone --depth 1 --single-branch -b "${BRANCH}" "${SPIRV_LLVM_TRANSLATOR_URL}" "${ROOT}/llvm-project/llvm/projects/SPIRV-LLVM-Translator"
fi

if [[ -n "${ROCM_DEVICE_LIBS_URL}" ]]; then
    # Checkout ROCm Device Libraries
    git clone --depth 1 --single-branch -b "${ROCM_DEVICE_LIBS_BRANCH}" "${ROCM_DEVICE_LIBS_URL}" "${ROOT}/llvm-project/llvm/projects/Device-Libs"
fi

df -h /

# Setup build directory and build configuration
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
if [[ $GCC_VERSION == "4."* ]]; then
   export LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${LIBRARY_PATH}"
fi
cmake \
    -G "Ninja" "${ROOT}/llvm-project/llvm" \
    -DLLVM_ENABLE_PROJECTS="${LLVM_ENABLE_PROJECTS}" \
    -DLLVM_ENABLE_RUNTIMES="${LLVM_ENABLE_RUNTIMES}" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${STAGING_DIR}" \
    -DCMAKE_C_COMPILER:PATH="/opt/compiler-explorer/gcc-${GCC_VERSION}/bin/gcc" \
    -DCMAKE_CXX_COMPILER:PATH="/opt/compiler-explorer/gcc-${GCC_VERSION}/bin/g++" \
    -DLLVM_BINUTILS_INCDIR:PATH="/opt/compiler-explorer/gcc-${GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${GCC_VERSION}/plugin/include" \
    -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="${LLVM_EXPERIMENTAL_TARGETS_TO_BUILD}" \
    -DLLVM_PARALLEL_LINK_JOBS=4 \
    "${CMAKE_EXTRA_ARGS[@]}"

# Build and install artifacts
ninja ${NINJA_TARGET} "${NINJA_EXTRA_TARGETS[@]}"
if [[ -n "${NINJA_TARGET_RUNTIMES}" ]]; then
    ninja "${NINJA_TARGET_RUNTIMES}"
fi
if [[ -n "${NINJA_EXTRA_TARGETS_NO_FAIL}" ]]; then
    ninja -k0 "${NINJA_EXTRA_TARGETS_NO_FAIL[@]}" || true
fi

# Don't try to compress the binaries as they don't like it

# export XZ_DEFAULTS="-T 0"
# tar Jcf "${OUTPUT}" --transform "s,^./,./${FULLNAME}/," -C "${STAGING_DIR}" .


echo "ce-build-status:OK"
