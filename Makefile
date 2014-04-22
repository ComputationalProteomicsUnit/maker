## ideas and most of the code stolen from https://github.com/tudo-r/makeR
## updated to be run outside of the package directory

ifeq (${R_HOME},)
R_HOME = $(shell R RHOME)
endif

R                  := "$(R_HOME)/bin/R" --vanilla
RSCRIPT            := "$(R_HOME)/bin/Rscript" --vanilla
RM                 := rm -rf
PKG                := maker## default package (there must be no whitespace behind the PKG name)
VERSION            := $(shell grep -s Version ${PKG}/DESCRIPTION | sed -e 's/Version: //')
TARGZ              := ${PKG}_${VERSION}.tar.gz
BUILDARGS          := --no-build-vignettes
CHECKARGS          := --no-vignettes --no-build-vignettes
INSTALLARGS        := --install-tests
WARNINGS_AS_ERRORS := 1
VIG                := 1
CRAN               := 0
IGNORE             := ".git/* .svn/* sandbox/*"
IGNOREPATTERN      := $(shell echo "${IGNORE}" | sed 's:\([^[:space:]]\+\):-a -not -path "${PKG}/\1":g; s:^-a \+::')
PKGFILES           := $(shell find ${PKG} -type f \( ${IGNOREPATTERN} \))
VIGFILES           := $(shell find ${PKG} -type f -name *.Rnw)


ifeq (${VIG},1)
BUILDARGS := $(filter-out --no-build-vignettes,$(BUILDARGS))
CHECKARGS := $(filter-out --no-vignettes --no-build-vignettes,$(CHECKARGS))
endif

ifeq (${CRAN},1)
CHECKARGS += --as-cran
endif


.PHONEY: build vignettes check check-only check-downstream \
	check-reverse-dependencies clean clean-all clean-tar help \
	install install-only install-dependencies install-upstream \
	maker remove roxygen rd run-demos targets tests usage win-builder

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
	@echo " check-only                  - check package"
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
	@echo " remove                      - remove package"
	@echo " roxygen                     - roxygenize package"
	@echo " rd                          - roxygenize rd rocklet"
	@echo " run-demos                   - source and run demo/*.R files"
	@echo " targets                     - show this usage output"
	@echo " tests                       - run unit tests on installed package"
	@echo " usage                       - show this usage output"
	@echo " win-builder                 - build package and send to win-builder.r-project.org"
	@echo ""
	@echo " maker                       - updates maker toolbox"
	@echo ""
	@echo "Available variables:"
	@echo ""
	@echo " PKG                         - name of the target package (default is maker)"
	@echo " VIG                         - should vignettes be build (default is 1). If 0, build --no-build-vignettes is used"
	@echo " WARNINGS_AS_ERRORS          - fail on warnings (default is 1)"
	@echo " CRAN                        - check using --as-cran (default is 0)"
	@echo ""
	@echo "Misc:"
	@echo ""
	@echo " Vignettes are not build when checking: R CMD check --no-build-vignettes"

build: ${TARGZ}

${TARGZ}: ${PKGFILES}
	${R} CMD build ${BUILDARGS} ${PKG}

vignettes:
	cd ${PKG}/vignettes/ && \
	for v in `ls *.Rnw`; do \
		${R} CMD Sweave --engine=knitr::knitr --pdf $$v; \
	done

check: | build check-only

check-only:
	${R} CMD check ${CHECKARGS} ${TARGZ} && \
	grep "WARNING" ${PKG}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNINGS_AS_ERRORS}; fi

check-reverse-dependencies check-downstream: install
	cd ${PKG} && ${RSCRIPT} ../maker/include/check-reverse-dependencies.R

clean:
	${RM} ${PKG}/src/*.o ${PKG}/src/*.so
	${RM} ${PKG}.Rcheck
	${RM} ${PKG}/*~
	find . -name '.Rhistory' -exec rm '{}' \;

clean-tar:
	${RM} ${TARGZ}

clean-vignettes:
	${RM} $(VIGFILES:.Rnw=.pdf) && \
	${RM} ${PKG}/vignettes/.build.timestamp

clean-all: clean clean-tar clean-vignettes

increment-version-major:
	@cd ${PKG} && ${RSCRIPT} ../maker/include/increment-version.R major

increment-version-minor:
	@cd ${PKG} && ${RSCRIPT} ../maker/include/increment-version.R minor

increment-version-patch:
	@cd ${PKG} && ${RSCRIPT} ../maker/include/increment-version.R patch

install: | build install-only

install-only:
	${R} CMD INSTALL ${INSTALLARGS} ${TARGZ}

install-dependencies install-upstream:
	cd ${PKG} && ${RSCRIPT} ../maker/include/install-dependencies.R

remove:
	${R} CMD REMOVE ${PKG}

roxygen: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKG)"')";

rd: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKG)"', roclets=\"rd\")";

run-demos:
	cd ${PKG} && ${RSCRIPT} ../maker/include/run-demos.R

tests:
	${R} -e "library('testthat'); test_package('"${PKG}"')"

win-builder: check
	ncftpput win-builder.r-project.org R-release ${TARGZ}

maker:
	cd maker && git checkout master && git pull

