#!/bin/sh

RED="\x1b[31;01m"
GREEN="\x1b[30;01m"
BLUE="\x1b[34;01m"
YELLOW="\x1b[33;01m"
CYAN="\x1b[1;36m"
NOCOLOUR="\x1b[0m"

if [ ${COLOURS} -eq 1 ] ; then
  sed 's#^.*NOTE.*$#'${YELLOW}'&'${NOCOLOUR}'#g;
       s#^.*CONSIDER.*$#'${CYAN}'&'${NOCOLOUR}'#g;
       s#^.*SKIPPED*$#'${BLUE}'&'${NOCOLOUR}'#g;
       s#^.*WARNING.*$#'${RED}'&'${NOCOLOUR}'#g;
       s#^.*RECOMMENDED.*$#'${RED}'&'${NOCOLOUR}'#g;
       s#^.*REQUIRED.*$#'${RED}'&'${NOCOLOUR}'#g;
       s#^.*ERROR.*$#'${RED}'&'${NOCOLOUR}'#g;
       s#^.*time: *\([3-9][0-9][0-9]\|[0-9]\{4,\}\)\.[0-9]\+.*$#'${RED}'& (check time should be < 5 min)'${NOCOLOUR}'#g;'
else
  cat
fi

