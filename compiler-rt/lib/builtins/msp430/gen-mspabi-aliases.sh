#!/bin/bash

{
  while read from to
  do
    file_name=../$(echo $from | sed 's/^_*//').c
    if test ! -f $file_name
    then
      echo "Skipping non-existing $file_name"
    elif grep '__MSP430__' $file_name > /dev/null
    then
      echo "Skipping $file_name"
    else
      echo "Updating $file_name"
      echo "#if defined(__MSP430__)" >> $file_name
      echo "COMPILER_RT_ALIAS($from, $to)" >> $file_name
      echo "#endif" >> $file_name
    fi
  done
} <<EndOfAliasList
__truncdfsf2 __mspabi_cvtdf
__extendsfdf2 __mspabi_cvtfd
__fixdfsi __mspabi_fixdli
__fixdfdi __mspabi_fixdlli
__fixunsdfsi __mspabi_fixdul
__fixunsdfdi __mspabi_fixdull
__fixsfsi __mspabi_fixfli
__fixsfdi __mspabi_fixflli
__fixunssfsi __mspabi_fixful
__fixunssfdi __mspabi_fixfull
__floatsidf __mspabi_fltlid
__floatdidf __mspabi_fltllid
__floatunsidf __mspabi_fltuld
__floatundidf __mspabi_fltulld
__floatsisf __mspabi_fltlif
__floatdisf __mspabi_fltllif
__floatunsisf __mspabi_fltulf
__floatundisf __mspabi_fltullf
__adddf3 __mspabi_addd
__addsf3 __mspabi_addf
__divdf3 __mspabi_divd
__divsf3 __mspabi_divf
__muldf3 __mspabi_mpyd
__mulsf3 __mspabi_mpyf
__subdf3 __mspabi_subd
__subsf3 __mspabi_subf
__divhi3 __mspabi_divi
__divsi3 __mspabi_divli
__divdi3 __mspabi_divlli
__udivhi3 __mspabi_divu
__udivsi3 __mspabi_divul
__udivdi3 __mspabi_divull
__modhi3 __mspabi_remi
__modsi3 __mspabi_remli
__moddi3 __mspabi_remlli
__umodhi3 __mspabi_remu
__umodsi3 __mspabi_remul
__umoddi3 __mspabi_remull
__lshrsi3 __mspabi_srll
__ashrsi3 __mspabi_sral
__ashlsi3 __mspabi_slll
__muldi3 __mspabi_mpyll
EndOfAliasList
