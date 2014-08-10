#!/usr/bin/env Rscript --vanilla

library("devtools")

deps <- as.package(".")[c("imports", "depends", "suggests", "linkingto")]
deps <- deps[!is.na(names(deps))]
deps <- lapply(deps, function(x)parse_deps(x)[, c("name", "version")])
deps <- do.call(rbind, deps)

installed <- installed.packages(fields=c("Package", "Version"))[, c("Package", "Version")]

deps$installed <- installed[, "Version"][match(deps$name, installed[, "Package"], nomatch=NA_character_)]

install <- is.na(deps$installed) |
           (!is.na(deps$version) &&
            package_version(deps$version) > package_version(deps$installed))

if (any(install)) {
  source("http://bioconductor.org/biocLite.R")
  biocLite(deps$name[install], ask = FALSE)
}

