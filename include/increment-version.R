#!/usr/bin/env Rscript --vanilla

arg <- match.arg(commandArgs(TRUE), c("major", "minor", "patch"))

dcf <- read.dcf("DESCRIPTION")

version <- dcf[, "Version"]
version <- as.numeric(strsplit(version, "\\.")[[1L]][1L:3L])
if (arg == "major") {
  version <- c(version[1L]+1L,
               0L,
               NA)
} else if (arg == "minor") {
  version <- c(version[1L],
               version[2L]+1L,
               NA)
} else if (arg == "patch") {
  version <- c(version[1L],
               version[2L],
               ifelse(is.na(version[3]), 1L, version[3]+1L))
}

dcf[, "Version"] <- paste(na.omit(version), collapse=".")
dcf[, "Date"] <- format(Sys.time(), "%Y-%m-%d")

write.dcf(dcf, "DESCRIPTION")

message("New version of ", dcf[, "Package"], " is ", dcf[, "Version"])

