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
declare -a COMMITS_TO_CHERRYPICK_AFTER_PATCHES

case $VERSION in
ce-trunk)
    BRANCH=dbg-to-stdout
    URL=https://github.com/compiler-explorer/llvm-project.git
    VERSION=ce-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_PROJECTS+=";pstl"
    CMAKE_EXTRA_ARGS+=("-DLIBCXX_ENABLE_PARALLEL_ALGORITHMS=ON")
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
    CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON" "-DLLVM_OPTIMIZED_TABLEGEN=ON")
    LLVM_ENABLE_RUNTIMES+=";libunwind"
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
    CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON" "-DLLVM_TARGETS_TO_BUILD=AArch64;ARM;X86")
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
p2561-trunk)
    BRANCH=P2561
    URL=https://github.com/vasama/llvm
    VERSION=p2561-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
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
p3334-trunk)
    BRANCH=p3334-cross-static
    URL=https://github.com/tal-yac/llvm-project
    VERSION=p3334-trunk-$(date +%Y%m%d)
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
p3385-trunk)
    BRANCH=3385R5
    URL=https://github.com/zebullax/clang-p2996/
    VERSION=p3385-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p3412-trunk)
    BRANCH=f-literals
    URL=https://github.com/BengtGustafsson/llvm-project-UTP.git
    VERSION=p3412-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
p3776-trunk)
    BRANCH=P3776-More-Trailing-Commas
    URL=https://github.com/term-est/llvm-project
    VERSION=p3776-trunk-$(date +%Y%m%d)
    LLVM_ENABLE_RUNTIMES+=";libunwind"
    ;;
implicit-constexpr-trunk)
    BRANCH=feature/implicit-constexpr-flag
    URL=https://github.com/hanickadot/llvm-project.git
    VERSION=implicit-constexpr-trunk-$(date +%Y%m%d)
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
        ROCM_VERSION=999999 # trunk builds are "infinitely" far into the future
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
    CMAKE_EXTRA_ARGS+=("-DLLVM_TARGETS_TO_BUILD=AMDGPU;X86")

    if (( ROCM_VERSION < 602 )); then
        LLVM_ENABLE_PROJECTS="clang;lld;clang-tools-extra;compiler-rt"
    else
        # Does not compile with 9.2
        GCC_VERSION=9.4.0
        LLVM_ENABLE_PROJECTS="clang;lld;clang-tools-extra"
        LLVM_ENABLE_RUNTIMES+=";libunwind;compiler-rt"
        CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=1")
    fi

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
        LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="DirectX;M68k"
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
        LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="DirectX;M68k"
        CMAKE_EXTRA_ARGS+=("-DLLVM_ENABLE_ASSERTIONS=ON" "-DCLANG_ENABLE_HLSL=On" "-DLIBCXX_INSTALL_MODULES=ON")
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
            if [[ ($MAJOR -eq 3 && $MINOR -ge 8) || $MAJOR -ge 4 ]]; then
                # Clang 3.7 and older specify set of testing targets separately
                # for each version.
                NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang" "check-cxx")
            fi
        fi
        TAG=llvmorg-${PURE_VERSION}

        if [[ $MAJOR -ge 18 ]]; then
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_INSTALL_MODULES=ON")
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
        elif [[ $MAJOR -le 21 ]]; then
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-13.patch")
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="M68k;WebAssembly"
        else
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-debug-clang-trunk.patch")
            LLVM_EXPERIMENTAL_TARGETS_TO_BUILD="M68k;WebAssembly"
        fi

        # Enable libunwind (useful for assertion builds but seemingly useful even if not)
        if [[ $MAJOR -lt 6 ]]; then
            # use older GCCs for 5 and earlier
            GCC_VERSION=5.5.0
            LLVM_ENABLE_PROJECTS+=";libunwind"
        else
            LLVM_ENABLE_RUNTIMES+=";libunwind"
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 7 ]]; then
            GCC_VERSION=5.5.0
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-libcxx-3.7-linker-script.patch")
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=ON") # Link against libc++abi.so when linking against libc++.so
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang" "check-libcxx")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 6 ]]; then
            GCC_VERSION=4.9.4
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-libcxx-3.6-compile-flags.patch")
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-libcxx-3.6-linker-script.patch")
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=ON") # Link against libc++abi.so when linking against libc++.so
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang" "check-libcxx")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 5 ]]; then
            GCC_VERSION=4.9.4
            COMMITS_TO_CHERRYPICK+=("cf6b0c64b96cecaf961ef59f2b1db87f08f30881") # __sync_swap fix
            COMMITS_TO_CHERRYPICK+=("f2f09fb32946a806f46285419fe6359f30206811") # fix the lack of lld targets; present in 3.5.2
            COMMITS_TO_CHERRYPICK+=("55d029e6ae67d173fd0fd218e62f9e359bb1bf34") # libc++: "Better defaults for in-tree libc++ with cmake."
            COMMITS_TO_CHERRYPICK+=("9d7323eca38f6ad0722306713ab7c5df5cf43b38") # libc++: "Fix linking with just-built libc++abi"
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-libcxx-3.5-linker-script.patch")
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=ON") # Link against libc++abi.so when linking against libc++.so
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang" "check-libcxx")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 4 ]]; then
            GCC_VERSION=4.8.5
            COMMITS_TO_CHERRYPICK+=("1d1b46cdf71bec1d95ca8a4665990972bd34bfc7") # "Make locales (and transitively, std::endl) work reliably with gcc."
            COMMITS_TO_CHERRYPICK+=("9e3548875a9fe7e959de608d3c279f1fe6c4594a") # "Add a _LIBCPP_CONSTEXPR that was missed in r170026."
            COMMITS_TO_CHERRYPICK+=("5a3d898758ed87f5d58e92d3ecdb75b567b059d6") # fix for -stdlib=libc++ header search paths
            COMMITS_TO_CHERRYPICK+=("902efc61be719775ccb15cb95ce6c2e79566dd5e") # fix for -stdlib=libc++ linker search paths
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-lld-3.4-missing-targets.patch")
            CMAKE_EXTRA_ARGS+=("-DCMAKE_CXX_FLAGS=-std=c++0x")
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_CXX_ABI=libsupc++") # Make libc++ link against libsupc++, so that users don't have to
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_LIBSUPCXX_INCLUDE_PATHS=/opt/compiler-explorer/gcc-${GCC_VERSION}/include/c++/${GCC_VERSION};/opt/compiler-explorer/gcc-${GCC_VERSION}/include/c++/${GCC_VERSION}/x86_64-linux-gnu/")
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang" "check-libcxx")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 3 ]]; then
            GCC_VERSION=4.8.5
            COMMITS_TO_CHERRYPICK+=("1d1b46cdf71bec1d95ca8a4665990972bd34bfc7") # "Make locales (and transitively, std::endl) work reliably with gcc."
            COMMITS_TO_CHERRYPICK+=("9e3548875a9fe7e959de608d3c279f1fe6c4594a") # "Add a _LIBCPP_CONSTEXPR that was missed in r170026."
            COMMITS_TO_CHERRYPICK+=("4806fcd6974cd47a505e2b3e599b9a34da1e9899") # fix for "can't find '__main__' module" in libc++ tests
            COMMITS_TO_CHERRYPICK+=("18595440712c33ff2459ba1b900ad3d6819d2ecb") # fix for libc++ tests that don't pass '-std=c++0x' to compiler
            COMMITS_TO_CHERRYPICK+=("902efc61be719775ccb15cb95ce6c2e79566dd5e") # fix for -stdlib=libc++ linker search paths
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-clang-3.3-libcxx-header-search-paths.patch")
            CMAKE_EXTRA_ARGS+=("-DCMAKE_CXX_FLAGS=-std=c++0x")
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_CXX_ABI=libsupc++") # Make libc++ link against libsupc++, so that users don't have to
            CMAKE_EXTRA_ARGS+=("-DLIBCXX_LIBSUPCXX_INCLUDE_PATHS=/opt/compiler-explorer/gcc-${GCC_VERSION}/include/c++/${GCC_VERSION};/opt/compiler-explorer/gcc-${GCC_VERSION}/include/c++/${GCC_VERSION}/x86_64-linux-gnu/")
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang" "check-libcxx")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 2 ]]; then
            GCC_VERSION=4.4.7
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check-llvm" "check-clang")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 1 ]]; then
            GCC_VERSION=4.4.7
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check" "clang-test")
        fi

        if [[ $MAJOR -eq 3 && $MINOR -eq 0 ]]; then
            GCC_VERSION=4.4.7
            COMMITS_TO_CHERRYPICK+=("00221ce63d450f9d024f437d7fb6bfa71b18f7a7") # exportsfile fix
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check" "clang-test")
        fi

        if [[ $MAJOR -eq 2 && $MINOR -eq 9 ]]; then
            GCC_VERSION=4.5.3
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check" "clang-test")
        fi
        
        if [[ $MAJOR -eq 2 && $MINOR -eq 8 ]]; then
            GCC_VERSION=4.5.3
            COMMITS_TO_CHERRYPICK+=("95b6f045f1f104b96d443c404755c2757b6f6cf7") # prerequisite for symlink fix below
            COMMITS_TO_CHERRYPICK+=("16d73f92161ae43828fd6dfaa3bb887058352bcb") # fix for clang++ symlink being absolute
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-llvm-2.8-disable-cast-fp-test.patch") # cast-fp.ll takes 98 GB of RAM and 4 minutes to fail
            NINJA_EXTRA_TARGETS_NO_FAIL+=("check" "clang-test")
        fi

        if [[ $MAJOR -eq 2 && $MINOR -eq 7 ]]; then
            GCC_VERSION=4.4.7
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-clang-2.7-clang-symlink-prerequisite.patch")
            PATCHES_TO_APPLY+=("${ROOT}/patches/ce-clang-2.7-default-to-intel-asm-syntax.patch")
            COMMITS_TO_CHERRYPICK_AFTER_PATCHES+=("16d73f92161ae43828fd6dfaa3bb887058352bcb") # fix for clang++ symlink being absolute
            # Not adding LLVM tests ("check" target), because they expect AT&T syntax.
            NINJA_EXTRA_TARGETS_NO_FAIL+=("clang-test")
        fi

        if [[ $MAJOR -eq 2 && $MINOR -eq 6 ]]; then
            GCC_VERSION=4.4.7
            COMMITS_TO_CHERRYPICK+=("ccc60da5c7bef1c454b27056dfb1b003ad71807e") # enable Clang frontend for C++ and ObjC inputs
            # Not adding LLVM tests ("check" target), because they are not available via CMake.
            NINJA_EXTRA_TARGETS_NO_FAIL+=("clang-test")
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
    # It was found out that --depth=1 is not enough sometimes,
    # so fetching with --depth=10 to ensure that cherry-pick succeeds.
    git -C "${ROOT}/llvm-project" fetch --depth=10 origin "${COMMIT_TO_CHERRYPICK}" -v
    git -C "${ROOT}/llvm-project" cherry-pick -n "${COMMIT_TO_CHERRYPICK}" -v
done

for PATCH_TO_APPLY in "${PATCHES_TO_APPLY[@]}"; do
    git -C "${ROOT}/llvm-project" apply "${PATCH_TO_APPLY}" -v
done

for COMMIT_TO_CHERRYPICK in "${COMMITS_TO_CHERRYPICK_AFTER_PATCHES[@]}"; do
    # It was found out that --depth=1 is not enough sometimes,
    # so fetching with --depth=10 to ensure that cherry-pick succeeds.
    git -C "${ROOT}/llvm-project" fetch --depth=10 origin "${COMMIT_TO_CHERRYPICK}" -v
    git -C "${ROOT}/llvm-project" cherry-pick -n "${COMMIT_TO_CHERRYPICK}" -v
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

# LLVM 4.0 was the version where LLVM_ENABLE_PROJECTS was introduced,
# In older versions, users were supposed to clone subprojects into the right
# places, and LLVM's CMakeLists would pick them up if they are present.
# If they were not, they were silently ignored.
# 4.0 doesn't need symlinks for anything but libc++abi, 5.0 doens't need them
# at all. The fact that all subprojects are in the git monorepo seems to be
# an artifact of SVN to git migration.
# So, for older version we translate subprojects in LLVM_ENABLE_PROJECTS
# into symlinks right where old CMakeLists expect them to be.
if [[ $MAJOR -le 4 ]]; then
    OIFS=$IFS
    IFS=";"
    for p in ${LLVM_ENABLE_PROJECTS}; do
        case $p in
        clang)
            ln -s "${ROOT}/llvm-project/clang" "${ROOT}/llvm-project/llvm/tools/clang"
            ;;
        clang-tools-extra)
            ln -s "${ROOT}/llvm-project/clang-tools-extra" "${ROOT}/llvm-project/clang/tools/extra"
            ;;
        compiler-rt)
            ln -s "${ROOT}/llvm-project/compiler-rt" "${ROOT}/llvm-project/llvm/projects/compiler-rt"
            ;;
        libcxx)
            if [[ ($MAJOR -eq 3 && $MINOR -ge 4) || $MAJOR -eq 4 ]]; then
                ln -s "${ROOT}/llvm-project/libcxx" "${ROOT}/llvm-project/llvm/projects/libcxx"
            fi
            if [[ $MAJOR -eq 3 && $MINOR -eq 3 ]]; then
                rm -rf "${ROOT}/llvm-project/clang/runtime/libcxx"
                ln -s "${ROOT}/llvm-project/libcxx" "${ROOT}/llvm-project/clang/runtime/libcxx"
            fi
            # Skip libc++ 3.2. It requires a lot of backported patches to build
            # it, run tests, and make `-stdlib=libc++` work without linker
            # complaining about libsupc++ symbols.
            ;;
        libcxxabi)
            if [[ ($MAJOR -eq 3 && $MINOR -ge 5) || $MAJOR -eq 4 ]]; then
                ln -s "${ROOT}/llvm-project/libcxxabi" "${ROOT}/llvm-project/llvm/projects/libcxxabi"
            fi
            ;;
        libunwind)
            ln -s "${ROOT}/llvm-project/libunwind" "${ROOT}/llvm-project/llvm/projects/libunwind"
            ;;
        lld)
            ln -s "${ROOT}/llvm-project/lld" "${ROOT}/llvm-project/llvm/tools/lld"
            ;;
        polly)
            # Polly in LLVM 3.7 and on has libisl 0.15 checked out into the repository.
            # Before that, Polly relied on `find_package(Isl REQUIRED)`,
            # where `FindIsl.cmake` is provided by Polly.
            # It searches for the library in the host system.
            # Ubuntu 16.04 has libisl-dev 0.16 in the repositories,
            # but it seems to be too new, because build fails.
            # So we keep Polly disabled until 3.7.
            if [[ ($MAJOR -eq 3 && $MINOR -ge 7) || $MAJOR -eq 4 ]]; then
              ln -s "${ROOT}/llvm-project/polly" "${ROOT}/llvm-project/llvm/tools/polly"
            fi
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

# We can't simply throw all test targets into a single ninja invocation,
# because it was observed that sometimes failing tests can prevent other tests
# from running even with '-k0' specified.
for TARGET in "${NINJA_EXTRA_TARGETS_NO_FAIL[@]}"; do
    # Starting with 3.2, python processes spawned by lit are trying to close 
    # the full range of possible file descriptors before exiting. On machines
    # with raised limit of open file descriptors, this can take minutes per
    # each of thousands of tests. One scenario is a dev machine where
    # 'fs.inotify.max_user_watches' was raised per Visual Studio Code request.
    # So we need to make sure that tests are run with a rather low limit.
    # See https://github.com/python/cpython/issues/127177 for details.
    prlimit --nofile=1024:524288 ninja -k0 "${TARGET}" || true
done

if [[ $MAJOR -le 3 ]]; then
    # It's very much worth testing that ancient versions of Clang are capable
    # of compiling C++ "Hello, world!", especially in `-stdlib=libc++` mode.
    # Use `-gcc-toolchain`, `-Wl,-rpath`, and `LD_LIBRARY_PATH` to do a rough
    # emulation of what's happening in production.
    export LD_LIBRARY_PATH=${ROOT}/staging/lib
    echo -e "#include <iostream>\n int main() { std::cout << \"Hello, world!\" << std::endl; }" > ${ROOT}/hello.cpp
    if [[ $MAJOR -eq 3 && $MINOR -ge 3 ]]; then
        ${ROOT}/staging/bin/clang++ \
            -gcc-toolchain /opt/compiler-explorer/gcc-${GCC_VERSION} \
            -Wl,-rpath=/opt/compiler-explorer/gcc-${GCC_VERSION}/lib64 \
            -stdlib=libc++ \
            -o ${ROOT}/hello_libcxx \
            ${ROOT}/hello.cpp && \
        ${ROOT}/hello_libcxx && \
        rm ${ROOT}/hello_libcxx || true
    fi
    if [[ $MAJOR -eq 3 && $MINOR -ge 1 ]]; then
        ${ROOT}/staging/bin/clang++ \
            -gcc-toolchain /opt/compiler-explorer/gcc-${GCC_VERSION} \
            -Wl,-rpath=/opt/compiler-explorer/gcc-${GCC_VERSION}/lib64 \
            -o ${ROOT}/hello \
            ${ROOT}/hello.cpp && \
        ${ROOT}/hello && \
        rm ${ROOT}/hello || true
    fi
    if [[ ($MAJOR -eq 3 && $MINOR -eq 0) || ($MAJOR -eq 2 && $MINOR -eq 8) ]]; then
        ${ROOT}/staging/bin/clang++ \
            -I/opt/compiler-explorer/gcc-${GCC_VERSION}/include/c++/${GCC_VERSION} \
            -I/opt/compiler-explorer/gcc-${GCC_VERSION}/include/c++/${GCC_VERSION}/x86_64-linux-gnu/ \
            -I/opt/compiler-explorer/gcc-${GCC_VERSION}/lib/gcc/x86_64-linux-gnu/${GCC_VERSION}/include \
            -Wl,-rpath=/opt/compiler-explorer/gcc-${GCC_VERSION}/lib64 \
            -o ${ROOT}/hello \
            ${ROOT}/hello.cpp && \
        ${ROOT}/hello && \
        rm ${ROOT}/hello || true
    fi
    rm ${ROOT}/hello.cpp
    unset LD_LIBRARY_PATH
    # Clang 2.9 can't find GCC, so it passes crtbegin.o and friends to ld using
    # relative paths, which is not supported.
    # Clang 2.7 can't compile hello world (even C one) because of codegen bugs.
    # Clang 2.6 didn't officially support C++ at all.
fi

# Don't try to compress the binaries as they don't like it

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" --transform "s,^./,./${FULLNAME}/," -C "${STAGING_DIR}" .


echo "ce-build-status:OK"
