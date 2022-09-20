# RV128 code using LLP128D ABI.
# ABI not in emulation name to avoid breaking backward compatibility.
source_sh ${srcdir}/emulparams/elf128lriscv-defs.sh
OUTPUT_FORMAT="elf128-littleriscv"
 
# On Linux, first look for 128 bit LP128D target libraries in /lib128/llp128d as per
# the glibc ABI, and then /lib128 for backward compatility.
case "$target" in
  riscv128*-linux*)
    case "$EMULATION_NAME" in
      *128*)
        LIBPATH_SUFFIX="128/llp128d 128";;
    esac
    ;;
esac
