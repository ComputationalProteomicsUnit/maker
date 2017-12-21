#!/bin/bash
if [[ -f NEWS.md ]] ; then
    sed '/^# .*$$/d; /^## .*$$/{s/^## //g; p; s/./-/g}; /^###\+/{s/./\u&/g}; s/^##\+ //g; 1,2{/^[[:space:]]*$$/d}; s/\[\(#[0-9]\+\)\]([^)]\+)/\1/g' NEWS.md > NEWS
    git add NEWS
fi
