#!/usr/bin/env Rscript --vanilla

dcf <- read.dcf("DESCRIPTION")

if ("Date" %in% colnames(dcf)) {
  dcf[, "Date"] <- as.character(Sys.Date())
} else {
  dcf <- cbind(dcf, `Date` = as.character(Sys.Date()) )
}

write.dcf(dcf, "DESCRIPTION")

