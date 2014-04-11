#!/usr/bin/env Rscript --vanilla

library("devtools")
library("knitr")

buildvig <- function() {
  wd <- getwd()
  on.exit(setwd(wd))

  tmpdir <- tempdir()
  file.copy(file.path(wd, "vignettes"), tmpdir, recursive=TRUE)
  tmpdir <- file.path(tmpdir, "vignettes")
  setwd(tmpdir)

  targetdir <- file.path(wd, "inst", "doc")
  dir.create(targetdir, showWarnings=FALSE, recursive=TRUE)

  files <- list.files(".", pattern="*.Rnw")
  pdfs <- gsub("*.Rnw$", ".pdf", files)

  for (i in seq(along=files)) {
    knit2pdf(files[i])
    file.copy(pdfs[i], file.path(targetdir, pdfs[i]), overwrite=TRUE)
  }
}

load_all()
buildvig()

