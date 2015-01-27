## ideas and most of the code stolen from https://github.com/tudo-r/makeR
## updated to be run outside of the package directory

ifndef R_HOME
  R_HOME = $(shell R RHOME)
endif

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
RELEASERARGS       := --no-save --no-restore --no-site-file --no-environ# --vanilla-=--no-init-file
RELEASETARGETS     := | clean-all build check-only
INSTALLARGS        := --install-tests
IGNORE             := ".git/* .svn/* sandbox/*"
IGNOREPATTERN      = $(shell echo "${IGNORE}" | sed 's:\([^[:space:]]\+\):-a -not -path "${PKGDIR}/\1":g; s:^-a \+::')
MAKERDIR           := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
INCLUDEDIR         := ${MAKERDIR}/include/
PKGFILES           = $(shell find ${PKGDIR} -type f \( ${IGNOREPATTERN} \) 2>/dev/null)
VIGFILES           = $(shell find ${PKGDIR} -type f -name *.Rnw 2>/dev/null)
MAKERVERSION       := $(shell cd ${MAKERDIR} && git log -1 --format="%h [%ci]")

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

.DEFAULT_GOAL:= help

## overwrite default variables by variables in ~/.makerrc
ifneq ($(wildcard ${MAKERRC}),)
  include ${MAKERRC}
endif

## test whether PKGDIR is an R package
## if not throw an error if the user ask for a PKG-specific target
ifeq ($(wildcard ${PKGDIR}/DESCRIPTION),)
ifneq ($(filter-out get-default-pkg help maker targets usage version,${MAKECMDGOALS}),)
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

help targets usage:
	@echo "Usage:"
	@echo ""
	@echo " make TARGET PKG=package"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo " build                       - build source package"
	@echo " vignettes                   - build vignettes in ./\$${PKGDIR}/vignettes"
	@echo " check                       - build and check package"
	@echo " check-only                  - check package and time checking"
	@echo " bioccheck                   - build, check and BiocCheck package"
	@echo " bioccheck-only              - BiocCheck package"
	@echo " check-downstream            - check packages which depend on this package"
	@echo " check-reverse-dependencies  - check packages which depend on this package"
	@echo " clean                       - remove temporary files and .Rcheck"
	@echo " clean-tar                   - remove .tar.gz archive"
	@echo " clean-vignettes             - remove vignettes in inst/doc/"
	@echo " clean-all                   - combine \"clean\", \"clean-tar\" and  \"clean-vignettes\""
	@echo " compile-attributes          - run Rcpp::compileAttributes()"
	@echo " help                        - show this usage output"
	@echo " increment-version-major     - increment major version number (X++.1) and set the \"Date\" field in the DESCRIPTION file"
	@echo " increment-version-minor     - increment minor version number (1.X++) and set the \"Date\" field in the DESCRIPTION file"
	@echo " increment-version-patch     - increment patch version number (1.1.X++) and set the \"Date\" field in the DESCRIPTION file"
	@echo " install                     - build and install package"
	@echo " install-only                - install package"
	@echo " install-dependencies        - install package dependencies"
	@echo " install-upstream            - install package dependencies"
	@echo " release                     - build package for Bioc/CRAN release (includes vignettes etc.)"
	@echo " remove                      - remove package"
	@echo " roxygen                     - roxygenize package"
	@echo " rd                          - roxygenize rd rocklet"
	@echo " run-demos                   - source and run demo/*.R files"
	@echo " targets                     - show this usage output"
	@echo " usage                       - show this usage output"
	@echo " win-builder                 - build package and send to win-builder.r-project.org"
	@echo ""
	@echo " get-default-pkg             - print current default PKG"
	@echo " set-default-pkg             - set new default PKG"
	@echo " remove-default-pkg          - remove current default PKG"
	@echo ""
	@echo " maker                       - updates maker toolbox"
	@echo " version                     - prints latest git hash and date of maker"
	@echo ""
	@echo "Available variables:"
	@echo ""
	@echo " PKG/PKGDIR                  - path to the target package (default is 'maker')"
	@echo " MAKERRC                     - path to the maker configuration file (default is '${MAKERRC}')"
	@echo " VIG                         - should vignettes be build (default is 1). If 0, build --no-build-vignettes is used"
	@echo " WARNINGS_AS_ERRORS          - fail on warnings (default is 1)"
	@echo " CRAN                        - check using --as-cran (default is 0)"
	@echo " COLOURS                     - using colours for R CMD check results (default is 1)"
	@echo " RPROFILE                    - path to .Rprofile (default is ${INCLUDEDIR}/Rprofile)"
	@echo " TIMEFORMAT                  - time format (default: empty)"
	@echo ""
	@echo "Misc:"
	@echo ""
	@echo " Vignettes are not build when checking: R CMD check --no-build-vignettes"
	@echo ""
	@echo "Version:"
	@echo ""
	@echo " ${MAKERVERSION}"
	@echo ""

get-default-pkg:
	@grep "^[[:space:]]*PKG[[:space:]]*=" ${MAKERRC} || echo "No default PKG set."

remove-default-pkg:
	(test -f ${MAKERRC} && \
	sed -i --follow-symlinks '/^[[:space:]]*PKG[[:space:]]*=.*/d' ${MAKERRC})

set-default-pkg:
	(test -f ${MAKERRC} && \
	grep -q "^[[:space:]]*PKG[[:space:]]*=" ${MAKERRC} && \
	sed -i --follow-symlinks 's#^[[:space:]]*PKG[[:space:]]*=.*#PKG=${PKG}#' ${MAKERRC}) || \
	(echo PKG=${PKG} >> ${MAKERRC})
	@echo
	@echo "Default PKG set to ${PKG}."

## pseudo target to force evaluation of other targets, e.g. ${PKGBUILDFLAGSFILE}
force:

${PKGBUILDFLAGSFILE}: force
	echo "${VIG}" | cmp --silent - $@ || echo "${VIG}" > $@

build: clean ${TARGZ}

${TARGZ}: ${PKGFILES} ${PKGBUILDFLAGSFILE}
	${R} CMD build ${BUILDARGS} ${PKGDIR} | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh

vignettes:
	cd ${PKGDIR}/vignettes/ && \
		test -f Makefile && \
		make all || \
		( for v in $$(ls *.Rnw *.Rmd 2>/dev/null); do \
				${R} CMD Sweave --engine=knitr::knitr --pdf $$v; \
			done )

check: | build check-only

check-only:
	{ time ${TIMEFORMAT} ${R} CMD check ${CHECKARGS} ${TARGZ} 2>&1; } | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh && \
	grep "WARNING" ${PKGNAME}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNINGS_AS_ERRORS}; fi

bioccheck: | check bioccheck-only

bioccheck-only:
	${R} CMD BiocCheck ${TARGZ} 2>&1 | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh && \
	grep "WARNING" ${PKGNAME}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNINGS_AS_ERRORS}; fi

check-reverse-dependencies check-downstream: install
	cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/check-reverse-dependencies.R

clean:
	${RM} ${PKGDIR}/src/*.o ${PKGNAME}/src/*.so
	${RM} ${PKGDIR}/*~
	find . -name '.Rhistory' -exec rm '{}' \;
	${RM} ${PKGDIR}/vignettes/.\#*
	${RM} ${PKGDIR}/vignettes/\#*
	${RM} ${PKGNAME}.Rcheck

clean-tar:
	${RM} ${TARGZ}

clean-vignettes:
	test -f ${PKGDIR}/vignettes/Makefile && \
		(cd ${PKGDIR}/vignettes/ && make clean) || \
		( ${RM} $(VIGFILES:.Rnw=.pdf) && \
	    ${RM} ${PKGDIR}/vignettes/.build.timestamp )

clean-all: clean clean-tar clean-vignettes

compile-attributes:
	${R} -e "library(Rcpp); compileAttributes('"$(PKGDIR)"')";

increment-version-major:
	@cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R major

increment-version-minor:
	@cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R minor

increment-version-patch:
	@cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R patch

install: | build install-only

install-only:
	${R} CMD INSTALL ${INSTALLARGS} ${TARGZ} | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh

install-dependencies install-upstream:
	cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/install-dependencies.R

release: R := R_PROFILE_USER=${RPROFILE} ${R} ${RELEASERARGS}
release: CHECKARGS := ${RELEASECHECKARGS}
release: BUILDARGS := ${RELEASEBUILDARGS}
release: ${RELEASETARGETS}

remove:
	${R} CMD REMOVE ${PKGNAME}

roxygen: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKGDIR)"')";

rd: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKGDIR)"', roclets=\"rd\")";

run-demos:
	cd ${PKGDIR} && ${RSCRIPT} ${INCLUDEDIR}/run-demos.R

win-builder: check
	ncftpput win-builder.r-project.org R-release ${TARGZ}


maker: .maker

.maker:
	cd ${MAKERDIR} && git checkout master && git pull

version:
	@echo ${MAKERVERSION}

