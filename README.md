# [mpi-hs-binary](https://github.com/eschnett/mpi-hs-binary)

[MPI](https://www.mpi-forum.org) bindings for Haskell

* [GitHub](https://github.com/eschnett/mpi-hs): Source code repository
* [Hackage](http://hackage.haskell.org/package/mpi-hs): Haskell
  package and documentation
* [Stackage](https://www.stackage.org/package/mpi-hs): Stackage
  snapshots
* [Azure
  Pipelines](https://dev.azure.com/schnetter/mpi-hs/_build):
  Build Status [![Build
  Status](https://dev.azure.com/schnetter/mpi-hs/_apis/build/status/eschnett.mpi-hs?branchName=master)](https://dev.azure.com/schnetter/mpi-hs/_build/latest?definitionId=1&branchName=master)



## Overview

MPI (the Message Passing Interface) is widely used standard for
distributed-memory programming on HPC (High Performance Computing)
systems. MPI allows exchanging data (_messages_) between programs
running in parallel. There are several high-quality open source MPI
implementations (e.g. MPICH, MVAPICH, OpenMPI) as well as a variety of
closed-source implementations. These libraries can typically make use
of high-bandwidth low-latency communication hardware such as
InfiniBand.

This library `mpi-hs` provides Haskell bindings for MPI. It is based
on ideas taken from
[haskell-mpi](https://github.com/bjpop/haskell-mpi),
[Boost.MPI](https://www.boost.org/doc/libs/1_64_0/doc/html/mpi.html),
and [MPI for Python](https://mpi4py.readthedocs.io/en/stable/).

`mpi-hs` provides two API levels: A low-level API gives rather direct
access to the MPI API, apart from certain "reasonable" mappings from C
to Haskell (e.g. output arguments that are in C stored to a pointer
are in Haskell regular return values). A high-level API simplifies
exchanging arbitrary values that can be serialized.



## Example

This is a typical MPI C code:
```C
#include <stdio.h>
#include <mpi.h>

int main(int argc, char** argv) {
  MPI_Init(&argc, &argv);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  printf("This is process %d of %d\n", rank, size);
  MPI_Finalize();
  return 0;
}
```

The Haskell equivalent looks like this:
```Haskell
import Control.Distributed.MPI as MPI

main :: IO ()
main =
  do MPI.init
     rank <- MPI.commRank MPI.commWorld
     size <- MPI.commSize MPI.commWorld
     putStrLn $ "This is process " ++ show rank ++ " of " ++ show size
     MPI.finalize
```



## Installing

`mpi-hs` requires an external MPI library to be available on the
system. How to install such a library is beyond the scope of these
instructions.

<!---
(It is important that the MPI library's include files, libraries, and
executables are installed consistently. A common source of problems is
that there are several MPI implementations available on a system, and
that the default include file `mpi.h`, the library `libmpi.a`, and/or
the executable `mpirun` are provided by different implementations.
This will lead to various problems, often segfaults, since neither the
operating system nor these libraries provide any protection against
such a mismatch.)
-->

In some cases, the MPI library will be installed in `/usr/include`,
`/usr/lib`, and `/usr/bin`, respectively. In this case, no further
configuration is necessary, and `mpi-hs` will build out of the box
with `stack build`.

For convenience, this package offers Cabal flags to handle several
common cases where the MPI library is not installed in a standard
location:

- OpenMPI on Debian Linux (package `openmpi-dev`): use `--flag
  mpi-hs:openmpi-debian`
- OpenMPI on Ubuntu Linux (package `openmpi-dev`): use `--flag
  mpi-hs:openmpi-ubuntu`
- OpenMPI on macOS with MacPorts (package `openmpi`): use `--flag
  mpi-hs:openmpi-macports`
- MPICH on Ubuntu Linux (package `openmpi-dev`): use `--flag
  mpi-hs:mpich-ubuntu`
- MPICH on macOS with MacPorts (package `openmpi`): use `--flag
  mpi-hs:mpich-macports`

For example, using the MPICH MPI implementation installed via MacPorts
on macOS, you build `mpi-hs` like this:

```sh
stack build --flag mpi-hs:mpich-macports
```

In the general case, if your MPI library/operating system combination
is not supported by a Cabal flag, you need to describe the location of
your MPI library in `stack.yaml`. This might look like:

```yaml
extra-include-dirs:
  - /usr/lib/openmpi/include
extra-lib-dirs:
  - /usr/lib/openmpi/lib
```

### Testing the MPI installation with a C program

To test your MPI installation independently of using Haskell, copy the
example MPI C code into a file `mpi-example.c`, and run these commands:

```sh
cc -I/usr/lib/openmpi/include -c mpi-example.c
cc -o mpi-example mpi-example.o -L/usr/lib/openmpi/lib -lmpi
mpirun -np 3 ./mpi-example
```

All three commands must complete without error, and the last command
must output something like

```
This is process 0 of 3
This is process 1 of 3
This is process 2 of 3
```

where the order in which the lines are printed can be random. (The
output might even be jumbled, i.e. the characters of the three lines
might be mixed up.)

If these commands do not work, then this needs to be corrected before
`mpi-hs` can work. If additional compiler options or libraries are
needed, then these need to be added to the `stack.yaml` configuration
file (for include and library paths; see `extra-include-dirs` and
`extra-lib-dirs` there) or the `package.yaml` configuration file (for
additional libraries; see `extra-libraries` there).



## Examples and Tests

### Running the example

To run the example provided in `src/Main.hs`:

```
stack build
mpiexec -n 3 stack exec example
```

### Running the tests

There are four test cases provided in `tests`:

```
stack build --test --no-run-tests
mpirun-openmpi-mp -np 3 --mca btl self,vader --oversubscribe stack exec -- $(stack path --dist-dir)/build/mpi-test/mpi-test && echo SUCCESS || echo FAILURE
mpirun-openmpi-mp -np 3 --mca btl self,vader --oversubscribe stack exec -- $(stack path --dist-dir)/build/mpi-test-binary/mpi-test-binary && echo SUCCESS || echo FAILURE
mpirun-openmpi-mp -np 3 --mca btl self,vader --oversubscribe stack exec -- $(stack path --dist-dir)/build/mpi-test-serialize/mpi-test-serialize && echo SUCCESS || echo FAILURE
mpirun-openmpi-mp -np 3 --mca btl self,vader --oversubscribe stack exec -- $(stack path --dist-dir)/build/mpi-test-storable/mpi-test-storable && echo SUCCESS || echo FAILURE
mpirun-openmpi-mp -np 3 --mca btl self,vader --oversubscribe stack exec -- $(stack path --dist-dir)/build/mpi-test-store/mpi-test-store && echo SUCCESS || echo FAILURE
```
