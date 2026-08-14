#!/bin/bash

# Choose a compile-job count that fits the machine we actually got.
#
# A hardcoded job count goes stale in two directions. LLVM's per-translation-unit
# memory grows over time while the constant does not: the llvmflang cap was 24 in 2021
# (issue #27), cut to 12 in 2024 (#57), and by mid-2026 12 jobs at ~5GiB each no longer
# fitted the 64GiB runners either, so the nightly build OOMed every night from June
# onwards. Independently, a job can land on a smaller runner than intended, where any
# count chosen for a big machine is wrong from the start.
#
# Deriving the count from the RAM in front of us addresses both, and keeps addressing
# them without anyone having to notice.
#
# $1 = RAM to reserve per compile job, in GiB. Size it against observed *peak* RSS, not
#      the mean, since the peaks are what the OOM killer sees.
compile_jobs_for() {
    local gib_per_job=$1
    local mem_gib cpus jobs
    mem_gib=$(awk '/^MemTotal:/ { printf "%d", $2 / 1024 / 1024 }' /proc/meminfo)
    cpus=$(nproc)
    jobs=$((mem_gib / gib_per_job))
    # More jobs than cores buys nothing, and one job always has to be allowed.
    ((jobs > cpus)) && jobs=${cpus}
    ((jobs < 1)) && jobs=1
    echo "${jobs}"
}
