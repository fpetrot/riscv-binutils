	.data

	# On a 64-bit host the two values below will be read into a simple
	# 64-bit field in the expressionS structure and the type will be set
	# to O_constant.  On a 32-bit host however they will read into the
	# generic_bignum array and the type set to O_bignum.  Either way they
	# should both evaluate without errors.
	#
	# Note - some targets place .hword values on a 16-bit boundary, so we
	# declare a second, zero, .byte value in order to make the data
	# consistent across all targets.

	# FIXME : these constants are invalid in 128-bit. They represent either a very big positive number
	# or a very big negative number.
	# Use bignums two times as a workaround 
	# .byte  0xffffffffffffff98, 0
	# .hword 0xffffffffffff9876
	.byte  0xffffffffffffffffffffffffffffff98, 0
	.hword 0xffffffffffffffffffffffffffff9876

	# Check that on 64-bit hosts real bignum values also work.

	.byte  0xffffffffffffffffffffffffffffff98, 0
	.hword 0xffffffffffffffffffffffffffff9876

	# Also check a ridiculously long bignum value.

	.byte  0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff98, 0
