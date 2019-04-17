# Makefile for R packages

`maker` is based on https://github.com/tudo-r/makeR. This version has
been updated to be run outside of the package directory and reduce
external `Rscript` dependencies.

## Contact

You are welcome to:

* submit suggestions and bug-reports at:
	<https://github.com/ComputationalProteomicsUnit/maker/issues>

* fork and send a pull request on:
	<https://github.com/ComputationalProteomicsUnit/maker/>

* compose an e-mail to: <mail@sebastiangibb.de>

## Integrate `maker` into your project

Our version of `maker` is meant to be installed and run outside of the
package directory. Start by cloning `maker` (for example in the base
directory that contains your `R` package(s)), create the appropriate
symlinks and use it.

	git clone git@github.com:ComputationalProteomicsUnit/maker.git
	ln -s maker/Makefile .
	make help

## Update `maker`

	make maker

## Help

```sh
$ make help

Usage:

  make TARGET PKG=package
	e.g. make build PKG=MSnbase

Build:

  build                       build source package
  vignettes                   build vignettes in ./${PKGDIR}/vignettes/
  compile-attributes          run Rcpp::compileAttributes()
  release                     build package for Bioc/CRAN release (includes vignettes etc.)

Check:

  check                       build and check package; the check will always use "--no-vignettes" because vignettes are checked by the build process before
  check-only                  check package and time checking
  bioccheck                   build, check and BiocCheck package
  bioccheck-only              BiocCheck package
  check-reverse-dependencies  check packages which depend on this package
  check-downstream            check packages which depend on this package

Clean:

  clean                       remove temporary files and .Rcheck
  clean-tar                   remove .tar.gz archive
  clean-vignettes             remove vignettes in inst/doc/
  clean-all                   combine "clean", "clean-tar" and "clean-vignettes"

Increment version:

  increment-version-major     increment major version number (X++.1) and set the "Date" field in the DESCRIPTION file
  increment-version-minor     increment minor version number (1.X++) and set the "Date" field in the DESCRIPTION file
  increment-version-patch     increment patch version number (1.1.X++) and set the "Date" field in the DESCRIPTION file

Adminstration:

  install                     build and install package
  install-only                install package
  remove                      remove package

Documentation:

  roxygen                     roxygenize package
  rd                          roxygenize rd rocklet
  pkg-home                    pkgdown home
  pkg-news                    pkgdown news
  pkg-refs                    pkgdown references (manuals)
  pkg-vigs                    pkgdown articles (Rmd vignettes)
  pkg-all                     pkgdonw home, refs, articles and news (in that order)
  pkgdown                     full pkgdown site using the pkgdown::build_site
  README.md                   knit README.Rmd if available
  NEWS                        create plain text NEWS from NEWS.md if available

Maker specific targets:

  maker                       update maker toolbox
  maker-README.md             update help output in README.md
  version                     prints latest git hash and date of maker

Available variables:

  PKG/PKGDIR                  path to the target package (default is 'maker')
  MAKERRC                     path to the maker configuration file (default is '~/.makerrc')
  VIG                         vignettes be build (default is 1). If 0, build --no-build-vignettes is used
  WARNINGS_AS_ERRORS          fail on warnings (default is 1)
  CRAN                        check using --as-cran (default is 0)
  COLOURS                     using colours for R CMD check results (default is 1)
  RPROFILE                    path to .Rprofile (default is ${MAKEDIR}/include/Rprofile)
  TIMEFORMAT                  time format (default: empty)

Misc:

  Vignettes are not build when checking: R CMD check --no-build-vignettes

  win-builder                 build package and send to win-builder.r-project.org
  run-demos                   source and run demo/*.R files
  get-default-pkg             print current default PKG
  set-default-pkg             set new default PKG
  remove-default-pkg          remove current default PKG

Getting help:

  help target usage           print this help text

 Create an issue on https://github.com/ComputationalProteomicsUnit/maker/issues/ or
 write an e-mail to Sebastian Gibb <mail@sebastiangibb.de> and Laurent Gatto <laurent.gatto@uclouvain.be>.
```

## Additional targets via external Makefile

To add new project specific target to `maker`, you could create a
`makefiles` directory in your main `maker` directory (defined as
`${MAKERDIR}`) and add the following to your `~/.makerrc` configuration
file:

	ADDMAKEFILESDIR := ${MAKERDIR}/makefiles/
	include ${ADDMAKEFILESDIR}/Makefile.*

to automatically include new Makefiles. See
[issue 8](https://github.com/ComputationalProteomicsUnit/maker/issues/8)
for a short discussion and an example.

## Configuration

You could specify your own default variables in `~/.makerrc`. Please see, e.g.
[.makerrc](.makerrc):

```basemake
## configuration Makefile for maker

## don't build vignettes
VIG  := 0

## always use --as-cran
CRAN := 1
```

The `~/.makerrc` file is a Makefile as well. So you can use every
supported Makefile command.

See the
[`Setting R_HOME`](https://github.com/ComputationalProteomicsUnit/maker/issues/11)
issue to use multiple `R` installations with `maker`.

## More recipes

See the [`RECIPES.md`](RECIPES.md) file for additional/contributed recipes.
