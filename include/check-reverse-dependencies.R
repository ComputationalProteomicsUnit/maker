#!/usr/bin/env Rscript --vanilla

library("devtools")

res <- revdep_check()
l <- sapply(res, length)

if (any(l != 0)) {
  stop("Check for ", paste0(names(res)[l], collapse=", "), " failed!")
}

message("everything fine")
