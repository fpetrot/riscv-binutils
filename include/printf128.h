#ifndef PRINTF128_H
#define PRINTF128_H

// Printf macros for int128_t print
#define PRIx128 "W"
#define PRId128 "Q"
#define PRIu128 "Y"
#define PRIo128 "y"

// Disable format warnings on these prints because PRI128 specifiers are not defined by GCC
#define printf128_internal(fn, ...)                                 \
    ({                                                              \
      _Pragma("GCC diagnostic push")                                \
      _Pragma("GCC diagnostic ignored \"-Wformat\"")                \
      _Pragma("GCC diagnostic ignored \"-Wformat-extra-args\"")     \
      fn(__VA_ARGS__);                                              \
      _Pragma("GCC diagnostic pop")                                 \
    })

#define printf128(fmt, ...) printf128_internal(printf, fmt, __VA_ARGS__)
#define sprintf128(buf, fmt, ...) printf128_internal(sprintf, buf, fmt, __VA_ARGS__)
#define fprintf128(stream, fmt, ...) printf128_internal(fprintf, stream, fmt, __VA_ARGS__)

#endif /* ! defined (PRINTF128_H) */
