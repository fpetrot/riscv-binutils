#!/usr/bin/bash

if [ $# -eq 0 ]
then
  echo "Usage: ./BUILD /prefix/path"
  exit 1
fi

mkdir build
cd build
../configure --target riscv128-unknown-elf --prefix "$1" CXXFLAGS='-g3 -O0' CFLAGS='-g3 -O0'
make -j$nproc
make install
cd -


