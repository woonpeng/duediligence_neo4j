#!/usr/bin/env bash
tempfile=$(mktemp)
filelist=$(find $1 ! -name $0)
for file in $filelist
do
  echo Updating $file
  j2 $file > $tempfile
  cat $tempfile > $file
  rm $tempfile
done
