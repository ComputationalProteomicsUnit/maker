#!/usr/bin/env Rscript --vanilla

cat(read.dcf("DESCRIPTION")[[1, "Version"]])
