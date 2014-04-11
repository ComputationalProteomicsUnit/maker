#!/usr/bin/env Rscript --vanilla

library("devtools")

rundemos <- function() {
  wd <- getwd()
  on.exit(setwd(wd))
  setwd(tempdir())
  files <- list.files(file.path(wd, "demo/"),
                      pattern="^.*\\.R$",
                      full.names=TRUE)
  invisible(lapply(files, function(x) {
    message(basename(x))
    source(x)
  }))
}

load_all(".")
rundemos()

