#!/bin/bash

input_dir=`pwd`/rttm
output_file=rttm_all

for file in `ls $input_dir`; do


xpref=${file%.*}
#echo $xpref
cat $input_dir/$file | awk -v pref=$xpref '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"_"pref " "$9" "$10 }'
done>$output_file
