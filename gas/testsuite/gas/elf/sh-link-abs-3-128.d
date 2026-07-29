#source: sh-link-abs.s
#readelf: -S
#notarget: alpha*-*-*
# .set directive doesn't work on alpha ports.

#...
 +\[ *[0-9]+\] +__patchable_function_entries +PROGBITS +[0-9a-f]+ +[0-9a-f]+
 +0+(2|4|8|10) +0+ +WAL +ABS +0 +[1248]+
#pass

