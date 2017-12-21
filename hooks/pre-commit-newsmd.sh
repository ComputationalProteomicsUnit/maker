#!/bin/bash
REPOURL=$(git config --get remote.origin.url | sed 's/^.*git@github.com:/https:\/\/github.com\//; s/.git$/\/issues\//g; s/\//\\\//g')

# Replace #XXX issue numbers by [#XXX](https://github.com/lgatto/MSnbase/issues/XXX
sed -i '/\(^\|[^[]\)#[0-9]\+[^]]\?/{s/#\([0-9]\+\)/[#\1]('${REPOURL}'\1)/g;h};${x;/./{x;q1};x;q0}' NEWS.md
## explanation:
## sed -i (in place replacement)
## /[^[]#[0-9]\+[^]]/ search for issues #XXX not already surounded by "["/"]"
## and apply the substition command just to this numbers
## {s/#\([0-9]\+\)/[#\1](https:\/\/github.com\/lgatto\/MSnbase\/issues\/\1)/g;}
## build the link
## "h" copy the result into the "hold space" (initial empty)
## ${x;/./{x;q1};x;q0} when add the end of file "$", swap "hold" and "pattern"
## space via "x", if now anything was found in the "pattern" space "/./" swap
## again and return 1 (q1); if nothing was found also swap and return 0 (q0)

if [[ $? -ne 0 ]]; then
    echo "Issue link in NEWS.md was modified by '$(basename ${0})' hook; please review and recommit"
    exit 1
fi
