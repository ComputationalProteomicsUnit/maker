#!/bin/sh

RED="\x1b[31;01m"
GREEN="\x1b[30;01m"
BLUE="\x1b[34;01m"
YELLOW="\x1b[33;01m"
NOCOLOUR="\x1b[0m"

if [ ${COLOURS} -eq 1 ] ; then
  sed 's#\(^.*NOTE.*$\)#'${YELLOW}'\1'${NOCOLOUR}'#g;
       s#\(^.*SKIPPED*$\)#'${BLUE}'\1'${NOCOLOUR}'#g;
       s#\(^.*WARNING.*$\)#'${RED}'\1'${NOCOLOUR}'#g;
       s#\(^.*ERROR.*$\)#'${RED}'\1'${NOCOLOUR}'#g;'
else
  cat
fi

