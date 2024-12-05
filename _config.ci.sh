#!/bin/bash
# shellcheck disable=SC2034  # the file is meant to be sourced so no exports needed

# Config and basic preparations suitable for our GHA environment.

# expect CCACHE_DIR, OUT_DIR and ROOTFS_{GLIBC,MUSL}_DIR to be set by the task definition
mkdir -p "$CCACHE_DIR" "$OUT_DIR" "$ROOTFS_GLIBC_DIR" "$ROOTFS_MUSL_DIR"

# enable ccache shims if ccache directory is specified
if [[ -n $CCACHE_DIR ]]; then
    # this is suitable for our builder image
    if [[ -e /usr/lib/ccache ]]; then
        export PATH="/usr/lib/ccache:$PATH"
    fi
fi

# we check out the VMR in the build script because we don't want to hardcode
# the tag/branch in the CI task definition
DOTNET_VMR_CHECKED_OUT=false
DOTNET_VMR_CHECKOUT="/vmr"
DOTNET_VMR_BRANCH="v9.0.0+loong.20241204"
DOTNET_VMR_REPO=https://github.com/loongson-community/dotnet.git

ROOTFS_GLIBC_IMAGE_TAG="$(cat "$(dirname "${BASH_SOURCE[0]}")"/rootfs-glibc-image-tag.txt)"
ROOTFS_MUSL_IMAGE_TAG="$(cat "$(dirname "${BASH_SOURCE[0]}")"/rootfs-musl-image-tag.txt)"

# For the dotnet build system
# see https://github.com/dotnet/runtime/issues/35727
STAGE2_EXTRA_CFLAGS="-O2 -pipe -march=la64v1.0 -mtls-dialect=desc"
STAGE2_EXTRA_CXXFLAGS="$STAGE2_EXTRA_CFLAGS"
STAGE2_EXTRA_LDFLAGS="-Wl,-O1 -Wl,--as-needed -Wl,-z,pack-relative-relocs -Wl,--hash-style=gnu"

# it may be better to align with dotnet upstream that still sticks with gzip
# so far
# the size savings are not very significant anyway with today's network
# bandwidth
REPACK_TARBALLS=false
