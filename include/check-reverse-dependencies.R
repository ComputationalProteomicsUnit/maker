#!/usr/bin/env Rscript --vanilla

library("devtools")

pkg <- read.dcf("DESCRIPTION")[[1,"Package"]]
res <- revdep_check(pkg)
l <- sapply(res, length)

if (any(l != 0)) {
  stop("Check for ", paste0(names(res)[l], collapse=", "), " failed!")
}

message("everything fine")
