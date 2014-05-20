## ideas and most of the code stolen from https://github.com/tudo-r/makeR
## updated to be run outside of the package directory

ifeq (${R_HOME},)
  R_HOME = $(shell R RHOME)
endif

R                  := "$(R_HOME)/bin/R"
RSCRIPT            := "$(R_HOME)/bin/Rscript"
RM                 := rm -rf
PKG                := maker## default package (there must be no whitespace behind the PKG name)
VERSION            := $(shell grep -s Version ${PKG}/DESCRIPTION | sed -e 's/Version: //')
TARGZ              := ${PKG}_${VERSION}.tar.gz
BUILDARGS          := --no-build-vignettes
CHECKARGS          := --no-vignettes --no-build-vignettes
RELEASERARGS       := --no-save --no-restore --no-site-file --no-environ# --vanilla-=--no-init-file
RELEASETARGETS     := | clean-all build check-only
INSTALLARGS        := --install-tests
IGNORE             := ".git/* .svn/* sandbox/*"
IGNOREPATTERN      := $(shell echo "${IGNORE}" | sed 's:\([^[:space:]]\+\):-a -not -path "${PKG}/\1":g; s:^-a \+::')
MAKERDIR           := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
INCLUDEDIR         := ${MAKERDIR}/include/
PKGFILES           := $(shell find ${PKG} -type f \( ${IGNOREPATTERN} \) 2>/dev/null)
VIGFILES           := $(shell find ${PKG} -type f -name *.Rnw 2>/dev/null)
MAKERVERSION       := $(shell cd ${MAKERDIR} && git log -1 --format="%h [%ci]")

PKGBUILDFLAGSFILE  := /tmp/${PKG}.buildflags

## user variables
WARNINGS_AS_ERRORS := 1
VIG                := 1
CRAN               := 0
BIOC               := $(shell grep -s "biocViews" ${PKG}/DESCRIPTION >/dev/null && echo 1 || echo 0)
COLOURS            := 1
RPROFILE           := ${INCLUDEDIR}/Rprofile
TIMEFORMAT         :=

## overwrite default variables by variables in ~/.makerrc
ifneq ($(wildcard ~/.makerrc),)
  include ~/.makerrc
endif

ifeq (${VIG},1)
  BUILDARGS := $(filter-out --no-build-vignettes,$(BUILDARGS))
  CHECKARGS := $(filter-out --no-vignettes --no-build-vignettes,$(CHECKARGS))
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
	force help install install-only install-dependencies install-upstream \
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
	@echo " vignettes                   - build vignettes in ./\$${PKG}/vignettes"
	@echo " check                       - build and check package"
	@echo " check-only                  - check package and time checking"
	@echo " bioccheck                   - build, check and BiocCheck package"
	@echo " bioccheck-only              - BiocCheck package"
	@echo " check-downstream            - check packages which depend on this package"
	@echo " check-reverse-dependencies  - check packages which depend on this package"
	@echo " clean                       - remove temporary files and .Rcheck"
	@echo " clean-tar                   - remove .tar.gz archive"
	@echo " clean-vignettes             - remove vignettes in inst/doc/"
	@echo " clean-all                   - combine \"clean\" and \"clean-all\""
	@echo " help                        - show this usage output"
	@echo " increment-version-major     - increment major version number (X++.1)"
	@echo " increment-version-minor     - increment minor version number (1.X++)"
	@echo " increment-version-patch     - increment patch version number (1.1.X++)"
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
	@echo " maker                       - updates maker toolbox"
	@echo " version                     - prints latest git hash and date of maker"
	@echo ""
	@echo "Available variables:"
	@echo ""
	@echo " PKG                         - name of the target package (default is maker)"
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

## pseudo target to force evaluation of other targets, e.g. ${PKGBUILDFLAGSFILE}
force:

${PKGBUILDFLAGSFILE}: force
	echo "${VIG}" | cmp --silent - $@ || echo "${VIG}" > $@

build: clean ${TARGZ}

${TARGZ}: ${PKGFILES} ${PKGBUILDFLAGSFILE}
	${R} CMD build ${BUILDARGS} ${PKG} | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh

vignettes:
	cd ${PKG}/vignettes/ && \
		test -f Makefile && \
		make all || \
		( for v in `ls *.Rnw`; do \
				${R} CMD Sweave --engine=knitr::knitr --pdf $$v; \
			done )

check: | build check-only

check-only:
	{ time ${TIMEFORMAT} ${R} CMD check ${CHECKARGS} ${TARGZ} 2>&1; } | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh && \
	grep "WARNING" ${PKG}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNINGS_AS_ERRORS}; fi

bioccheck: | check bioccheck-only

bioccheck-only:
	${R} CMD BiocCheck ${TARGZ} 2>&1 | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh && \
	grep "WARNING" ${PKG}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNINGS_AS_ERRORS}; fi

check-reverse-dependencies check-downstream: install
	cd ${PKG} && ${RSCRIPT} ${INCLUDEDIR}/check-reverse-dependencies.R

clean:
	${RM} ${PKG}/src/*.o ${PKG}/src/*.so
	${RM} ${PKG}.Rcheck
	${RM} ${PKG}/*~
	find . -name '.Rhistory' -exec rm '{}' \;
	${RM} ${PKG}/vignettes/.\#*
	${RM} ${PKG}/vignettes/\#*

clean-tar:
	${RM} ${TARGZ}

clean-vignettes:
	test -f ${PKG}/vignettes/Makefile && \
		(cd ${PKG}/vignettes/ && make clean) || \
		( ${RM} $(VIGFILES:.Rnw=.pdf) && \
	    ${RM} ${PKG}/vignettes/.build.timestamp )

clean-all: clean clean-tar clean-vignettes

increment-version-major:
	@cd ${PKG} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R major

increment-version-minor:
	@cd ${PKG} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R minor

increment-version-patch:
	@cd ${PKG} && ${RSCRIPT} ${INCLUDEDIR}/increment-version.R patch

install: | build install-only

install-only:
	${R} CMD INSTALL ${INSTALLARGS} ${TARGZ} | \
	COLOURS=$(COLOURS) ${INCLUDEDIR}/color-output.sh

install-dependencies install-upstream:
	cd ${PKG} && ${RSCRIPT} ${INCLUDEDIR}/install-dependencies.R

release: R := R_PROFILE_USER=${RPROFILE} ${R} ${RELEASERARGS}
release: CHECKARGS := ${RELEASECHECKARGS}
release: BUILDARGS := ${RELEASEBUILDARGS}
release: ${RELEASETARGETS}

remove:
	${R} CMD REMOVE ${PKG}

roxygen: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKG)"')";

rd: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKG)"', roclets=\"rd\")";

run-demos:
	cd ${PKG} && ${RSCRIPT} ${INCLUDEDIR}/run-demos.R

win-builder: check
	ncftpput win-builder.r-project.org R-release ${TARGZ}


maker: .maker

.maker:
	cd ${MAKERDIR} && git checkout master && git pull

version:
	@echo ${MAKERVERSION}

