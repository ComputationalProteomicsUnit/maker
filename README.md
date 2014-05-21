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

Available targets:

 build                       - build source package
 vignettes                   - build vignettes in ./${PKG}/vignettes
 check                       - build and check package
 check-only                  - check package and time checking
 bioccheck                   - build, check and BiocCheck package
 bioccheck-only              - BiocCheck package
 check-downstream            - check packages which depend on this package
 check-reverse-dependencies  - check packages which depend on this package
 clean                       - remove temporary files and .Rcheck
 clean-tar                   - remove .tar.gz archive
 clean-vignettes             - remove vignettes in inst/doc/
 clean-all                   - combine "clean" and "clean-all"
 help                        - show this usage output
 increment-version-major     - increment major version number (X++.1)
 increment-version-minor     - increment minor version number (1.X++)
 increment-version-patch     - increment patch version number (1.1.X++)
 install                     - build and install package
 install-only                - install package
 install-dependencies        - install package dependencies
 install-upstream            - install package dependencies
 release                     - build package for Bioc/CRAN release (includes vignettes etc.)
 remove                      - remove package
 roxygen                     - roxygenize package
 rd                          - roxygenize rd rocklet
 run-demos                   - source and run demo/*.R files
 targets                     - show this usage output
 usage                       - show this usage output
 win-builder                 - build package and send to win-builder.r-project.org

 maker                       - updates maker toolbox
 version                     - prints latest git hash and date of maker

Available variables:

 PKG                         - name of the target package (default is maker)
 VIG                         - should vignettes be build (default is 1). If 0, build --no-build-vignettes is used
 WARNINGS_AS_ERRORS          - fail on warnings (default is 1)
 CRAN                        - check using --as-cran (default is 0)
 COLOURS                     - using colours for R CMD check results (default is 1)
 RPROFILE                    - path to .Rprofile (default is ${INCLUDEDIR}/Rprofile)
 TIMEFORMAT                  - time format (default: empty)

Misc:

 Vignettes are not build when checking: R CMD check --no-build-vignettes

Version:

 1733627 [2014-05-19 19:52:42 +0200]
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

The `~/.makerrc` is a Makefile as well. So you can use every supported
Makefile command.
