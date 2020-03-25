#!/bin/sh

set -euxo pipefail

stack build --flag mpi-hs:mpich-macports --test --no-run-tests --haddock --no-haddock-deps

mpiexec -n 3 stack exec -- $(stack path --dist-dir)/build/mpi-test-binary/mpi-test-binary

echo 'Done.'
