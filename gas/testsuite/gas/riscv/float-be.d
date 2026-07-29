# source: float.s
# notarget: riscv128-*-*
# objdump: -sj .data
# as: -mbig-endian

.*:[ 	]+file format .*bigriscv

Contents of section \.data:
 0000 3f8ccccd 40019999 9999999a.*
