#!/bin/sh

if [ "$1" != "" ] ; then
  xmlpath=$1
else
  return
fi
if [ "$2" != "" ] ; then
  addr=$2
else
  addr=0
fi
if [ "$3" != "" ] ; then
  tagname=$3
else
  tagname="Value"
fi

find=0
xmobj=$(grep -A 7 "id=\"$addr\"" $xmlpath)
echo "$xmobj" | grep \<$tagname\> | sed -e "s/.*<$tagname>\(.*\)<\/$tagname>.*/\1/"
