#source: sh-link-common.s
#readelf: -S
#notarget: *-*-hpux*
# hpux has a non-standard common directive.

#...
 +\[ *[0-9]+\] +__patchable_function_entries +PROGBITS +[0-9a-f]+ +[0-9a-f]+
 +0+(2|4|8|10) +0+ +WAL +COM +0 +[1248]+
#pass

