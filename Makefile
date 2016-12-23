## ideas and most of the code stolen from https://github.com/tudo-r/makeR
## updated to be run outside of the package directory

## Documentation is done directly in the Makefile using roxygen2-like syntax.
## To document a target use #' directly after the target and it dependencies
## (in the same line). Use @section to start a new section and @note to create
## a new note in the help output.

R_HOME             = "$(shell R RHOME)"
R                  = "$(R_HOME)/bin/R"
RSCRIPT            = "$(R_HOME)/bin/Rscript"
RM                 := rm -rf
PKG                := maker## default package (there must be no whitespace behind the PKG name)
PKGDIR             = ${PKG}/
PKGNAME            = $(shell sed -n 's/Package: *//p' ${PKGDIR}/DESCRIPTION 2> /dev/null)
VERSION            = $(shell sed -n 's/Version: *//p' ${PKGDIR}/DESCRIPTION 2> /dev/null)
TARGZ              = ${PKGNAME}_${VERSION}.tar.gz
BUILDARGS          := --no-build-vignettes
CHECKARGS          := --no-vignettes --no-build-vignettes
RELEASERARGS       := --no-save --no-restore --no-site-file --no-environ --vanilla --no-init-file
RELEASETARGETS     := | clean-all build check-only
INSTALLARGS        := --install-tests
IGNORE             := ".git/* .svn/* sandbox/*"
IGNOREPATTERN      = $(shell echo "${IGNORE}" | sed 's:\([^[:space:]]\+\):-a -not -path "${PKGDIR}/\1":g; s:/\{2,\}:/:g; s:^-a \+::')
MAKERDIR           := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
INCLUDEDIR         := ${MAKERDIR}/include/
PKGFILES           = $(shell find ${PKGDIR} -type f \( ${IGNOREPATTERN} \) 2>/dev/null)
VIGFILES           = $(shell find ${PKGDIR} -type f -name *.Rnw 2>/dev/null)
MAKERVERSION       := $(shell cd ${MAKERDIR} && git log -1 --format="%h [%ci]")
## targets that don't need an R package (PKG could be empty)
NONPKGTARGETS      := get-default-pkg help maker targets usage version

PKGBUILDFLAGSFILE  := /tmp/${PKGNAME}.buildflags

## user variables
MAKERRC            := ~/.makerrc
WARNINGS_AS_ERRORS := 1
VIG                := 1
CRAN               := 0
BIOC               = $(shell grep -s "biocViews" ${PKGDIR}/DESCRIPTION >/dev/null && echo 1 || echo 0)
COLOURS            := 1
RPROFILE           := ${INCLUDEDIR}/Rprofile
TIMEFORMAT         :=

.DEFAULT_GOAL := help

## overwrite default variables by variables in ~/.makerrc
ifneq ($(wildcard ${MAKERRC}),)
  include ${MAKERRC}
endif

## test whether PKGDIR is an R package
## if not throw an error if the user ask for a PKG-specific target
ifeq ($(wildcard ${PKGDIR}/DESCRIPTION),)
ifneq ($(filter-out ${NONPKGTARGETS},${MAKECMDGOALS}),)
$(error ${PKGDIR} seems to be no R package. Did you set PKG/PKGDIR?)
endif
endif

ifeq (${VIG},1)
  BUILDARGS := $(filter-out --no-build-vignettes,$(BUILDARGS))
  CHECKARGS := $(filter-out --no-vignettes,$(CHECKARGS))
endif

ifeq (${CRAN},1)
  CHECKARGS += --as-cran
  RELEASECHECKARGSCHECKARGS += --as-cran
endif

ifeq (${BIOC},1)
  RELEASETARGETS += bioccheck-only
endif

.PHONEY: build vignettes check check-only bioccheck bioccheck-only \
	check-downstream check-reverse-dependencies clean clean-all clean-tar \
	compile-attributes force help install install-only install-dependencies install-upstream \
	maker .maker remove release roxygen rd run-demos \
	targets usage win-builder version

#'@section Usage
#'@note make TARGET PKG=package
#'@note   e.g. make build PKG=MSnbase

## pseudo target to force evaluation of other targets, e.g. ${PKGBUILDFLAGSFILE}
force:

${PKGBUILDFLAGSFILE}: force
	echo "${VIG}" | cmp --silent - $@ || echo "${VIG}" > $@

#'@section Build
build: clean ${TARGZ} #' build source package

${TARGZ}: ${PKGFILES} ${PKGBUILDFLAGSFILE}
	${R} CMD build ${BUILDARGS} ${PKGDIR} | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh

vignettes: #' build vignettes in ./${PKGDIR}/vignettes/
	cd ${PKGDIR}/vignettes/ && \
		test -f Makefile && \
		make all || \
		( for v in $$(ls *.Rnw *.Rmd 2>/dev/null); do \
				${R} CMD Sweave --engine=knitr::knitr --pdf $$v; \
			done )

compile-attributes: #' run Rcpp::compileAttributes()
	${R} -e "library(Rcpp); compileAttributes('"$(PKGDIR)"')";

release: export R_PROFILE_USER=${RPROFILE}
release: R := ${R} ${RELEASERARGS}
release: CHECKARGS := ${RELEASECHECKARGS}
release: BUILDARGS := ${RELEASEBUILDARGS}
release: ${RELEASETARGETS} #' build package for Bioc/CRAN release (includes vignettes etc.)

#'@section Check
check: CHECKARGS := $(filter-out --no-vignettes,$(CHECKARGS))
check: | build check-only #' build and check package; the check will always use "--no-vignettes" because vignettes are checked by the build process before

check-only: #' check package and time checking
	{ time ${TIMEFORMAT} ${R} CMD check ${CHECKARGS} ${TARGZ} 2>&1; } | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh && \
	grep "WARNING" ${PKGNAME}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNINGS_AS_ERRORS}; fi

bioccheck: | check bioccheck-only #' build, check and BiocCheck package

bioccheck-only: #' BiocCheck package
	${R} CMD BiocCheck ${TARGZ} 2>&1 | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh && \
	grep "WARNING" ${PKGNAME}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNINGS_AS_ERRORS}; fi

check-reverse-dependencies: #' check packages which depend on this package
check-downstream: #' check packages which depend on this package
check-reverse-dependencies check-downstream: install
	cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/check-reverse-dependencies.R

#'@section Clean
clean: #' remove temporary files and .Rcheck
	${RM} ${PKGDIR}/src/*.o ${PKGNAME}/src/*.so
	${RM} ${PKGDIR}/*~
	find . -name '.Rhistory' -exec rm '{}' \;
	${RM} ${PKGDIR}/vignettes/.\#*
	${RM} ${PKGDIR}/vignettes/\#*
	${RM} ${PKGNAME}.Rcheck

clean-tar: #' remove .tar.gz archive
	${RM} ${TARGZ}

clean-vignettes: #' remove vignettes in inst/doc/
	test -f ${PKGDIR}/vignettes/Makefile && \
		(cd ${PKGDIR}/vignettes/ && make clean) || \
		( ${RM} $(VIGFILES:.Rnw=.pdf) && \
	    ${RM} ${PKGDIR}/vignettes/.build.timestamp )

clean-all: clean clean-tar clean-vignettes #' combine "clean", "clean-tar" and "clean-vignettes"

#'@section Increment version
increment-version-major: #' increment major version number (X++.1) and set the "Date" field in the DESCRIPTION file
	@cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R major

increment-version-minor: #' increment minor version number (1.X++) and set the "Date" field in the DESCRIPTION file
	@cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R minor

increment-version-patch: #' increment patch version number (1.1.X++) and set the "Date" field in the DESCRIPTION file
	@cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R patch

#'@section Adminstration
install: | build install-only #' build and install package

install-only: #' install package
	${R} CMD INSTALL ${INSTALLARGS} ${TARGZ} | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh

install-dependencies install-upstream: '# install package dependencies
	cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/install-dependencies.R

remove: #' remove package
	${R} CMD REMOVE ${PKGNAME}

#'@section Documentation
roxygen: clean #' roxygenize package
	${R} -e "library(roxygen2); roxygenize('"$(PKGDIR)"')";

rd: clean #' roxygenize rd rocklet
	${R} -e "library(roxygen2); roxygenize('"$(PKGDIR)"', roclets=\"rd\")";

pkg-home: clean #' pkgdown home
	${R} -e "setwd('"$(PKGDIR)"'); library(pkgdown); build_home()";

pkg-news: clean #' pkgdown news
	${R} -e "setwd('"$(PKGDIR)"'); library(pkgdown); build_news()";

pkg-refs: clean #' pkgdown references (manuals)
	${R} -e "setwd('"$(PKGDIR)"'); library(pkgdown); build_reference()";

pkg-vigs: clean #' pkgdown articles (Rmd vignettes)
	${R} -e "setwd('"$(PKGDIR)"'); library(pkgdown); build_articles()";

pkgdown: clean #' full pkgdown site: home, refs, ariticles and news (in that order)
	${R} -e "setwd('"$(PKGDIR)"'); library(pkgdown); build_site()";

#'@section Maker specific targets
maker: .maker #' update maker toolbox

.maker:
	cd ${MAKERDIR} && git checkout master && git pull

version: #' prints latest git hash and date of maker
	@echo ${MAKERVERSION}

#'@section Available variables
#'@param PKG/PKGDIR path to the target package (default is 'maker')
#'@param MAKERRC path to the maker configuration file (default is '~/.makerrc')
#'@param VIG vignettes be build (default is 1). If 0, build --no-build-vignettes is used
#'@param WARNINGS_AS_ERRORS fail on warnings (default is 1)
#'@param CRAN check using --as-cran (default is 0)
#'@param COLOURS using colours for R CMD check results (default is 1)
#'@param RPROFILE path to .Rprofile (default is ${MAKEDIR}/include/Rprofile)
#'@param TIMEFORMAT time format (default: empty)

#'@section Misc
#'@note Vignettes are not build when checking: R CMD check --no-build-vignettes\n

win-builder: check #' build package and send to win-builder.r-project.org
	ncftpput win-builder.r-project.org R-release ${TARGZ}

run-demos: #' source and run demo/*.R files
	cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/run-demos.R

get-default-pkg: #' print current default PKG
	@grep "^[[:space:]]*PKG[[:space:]]*=" ${MAKERRC} || echo "No default PKG set."

set-default-pkg: #' set new default PKG
	(test -f ${MAKERRC} && \
	grep -q "^[[:space:]]*PKG[[:space:]]*=" ${MAKERRC} && \
	sed -i --follow-symlinks 's/^[[:space:]]*PKG[[:space:]]*=.*/PKG=${PKG}/' ${MAKERRC}) || \
	(echo PKG=${PKG} >> ${MAKERRC})
	@echo
	@echo "Default PKG set to ${PKG}."

remove-default-pkg: #' remove current default PKG
	(test -f ${MAKERRC} && \
	sed -i --follow-symlinks '/^[[:space:]]*PKG[[:space:]]*=.*/d' ${MAKERRC})

#'@section Getting help
help target usage: #' print this help text
	@sed -n "s/\\\\n/|/g; \
					 s/^#' *@section \(.*\)$$/\n\1:\n/p; \
					 s/^#' *@note \(.*\)$$/  \1/p; \
 				   s/^#' *@param \([^ ]*\) \+\(.*\)\$$/  \1\t\2/p; \
					 s/^\([^:]\+\):.*#' \([^@]\+\)\$$/  \1\t\2/p" $(MAKEFILE_LIST) | expand -t 30 | tr '|' '\n'
#'@note \n Create an issue on https://github.com/ComputationalProteomicsUnit/maker/issues/ or \n write an e-mail to Sebastian Gibb <mail@sebastiangibb.de> and Laurent Gatto <lg390@cam.ac.uk>.

