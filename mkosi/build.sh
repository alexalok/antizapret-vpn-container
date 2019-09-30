#!/bin/bash
set -e
# You need mkosi utility to build the container image.
# run as sudo -E ./build.sh for gpg to work

mkosi build
# mkosi.finalize has been renamed to prevent running it twice
# on mkosi 5 (mkosi 4 does not support mkosi.finalize feature yet)
./mkosi.finalize_
sha256sum mkosi.output/lxd/lxd.tar.xz
