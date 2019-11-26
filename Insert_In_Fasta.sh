#!/bin/bash
input="$1"
b='N'
#Here the $b contain the string you want to insert

while IFS= read -r line
do
if [[ $line =~ ^\> ]] ; then 
   # echo "found"
echo "$line"
else
    #echo "not found"
len=${#line}
mid=$(((len + 1) * $RANDOM / 32767))
c="${line:0:$mid}${b}${line:$mid}"
echo "$c"
fi
done < "$input"
