#!/usr/bin/env bash
# -*- coding: utf-8 -*-

#Bash script to create a pseduo long reads
i=0
while (( i++ < 25 )); do
  cp $1 "PseudoLR$i.fa"
  cat "PseudoLR$i.fa" >> all.fa
done

awk '/^>/{print ">contg" ++i; next}{print}' <all.fa > PLR.fa
rm -rf PseudoLR*
rm -rf all.fa
