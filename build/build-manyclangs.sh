#!/bin/bash

set -exo pipefail

git clone https://github.com/llvm/llvm-project.git
git clone https://github.com/elfshaker/elfshaker

cd llvm-project

# TODO - split $1 into yyyy/mm
# TODO - handle "daily" ?
PATH=${PATH}:$(realpath ../elfshaker/contrib)

manyclangs-build-month 2022 01

REVISION=TODO
OUTPUT=TODO - some

# todo output needs to be two things
echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"
