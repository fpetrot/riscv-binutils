# RV128 code using LL128 ABI.
source_sh ${srcdir}/emulparams/elf128lriscv-defs.sh
OUTPUT_FORMAT="elf128-littleriscv"

# On Linux, first look for 128 bit LL128 target libraries in /lib128/ll128 as per
# the glibc ABI, and then /lib128 for backward compatility.
case "$target" in
  riscv128*-linux*)
    case "$EMULATION_NAME" in
      *128*)
        LIBPATH_SUFFIX="128/ll128 64";;
    esac
    ;;
esac

