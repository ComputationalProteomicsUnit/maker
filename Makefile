## ideas and most of the code stolen from https://github.com/tudo-r/makeR
## updated to be run outside of the package directory

ifeq (${R_HOME},)
R_HOME = $(shell R RHOME)
endif

R                  := "$(R_HOME)/bin/R" --vanilla
RSCRIPT            := "$(R_HOME)/bin/Rscript" --vanilla
RM                 := rm -rf
RMDIR              := rmdir --ignore-fail-on-non-empty
PKG                := maker ## default package
VERSION            := $(shell grep -s Version ${PKG}/DESCRIPTION | sed -e 's/Version: //')
TARGZ              := ${PKG}_${VERSION}.tar.gz
BUILDARGS          := --no-build-vignettes
CHECKARGS          := --no-vignettes --no-build-vignettes
INSTALLARGS        := --install-tests
WARNINGS_AS_ERRORS := 1
VIG                := 1
CRAN               := 0


ifeq (${VIG},0)
BUILDARGS := $(filter-out --no-build-vignettes,$(BUILDARGS))
CHECKARGS := $(filter-out --no-vignettes --no-build-vignettes,$(CHECKARGS))
endif

ifeq (${CRAN},1)
CHECKARGS += --as-cran
endif


.PHONEY: build vignettes check check-only check-downstream		\
	check-reverse-dependencies clean clean-all clean-tar help	\
	install install-only install-dependencies install-upstream	\
	remove roxygen rd run-demos targets tests usage win-builder

help targets usage:
	@echo "Usage:"
	@echo ""
	@echo " make TARGET PKG=package"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo " build                       - build source package"
	@echo " vignettes                   - build vignettes in ./${PKG}/vignettes"
	@echo " check                       - build and check package"
	@echo " check-only                  - check package"
	@echo " check-downstream            - check packages which depend on this package"
	@echo " check-reverse-dependencies  - check packages which depend on this package"
	@echo " clean                       - remove temporary files and .Rcheck"
	@echo " clean-tar                   - remove .tar.gz archive"
	@echo " clean-vignettes             - remove vignettes in inst/doc/"
	@echo " clean-all                   - combine \"clean\" and \"clean-all\""
	@echo " help                        - show this usage output"
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

build:
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
	${RM} src/*.o src/*.so
	${RM} ${PKG}.Rcheck
	find . -name '.Rhistory' -exec rm '{}' \;
	rm -f *~

clean-tar:
	${RM} ${TARGZ}

clean-vignettes:
	cd ${PKG} && ${RSCRIPT} ../maker/include/clean-vignettes.R && \
	${RMDIR} inst/doc && ${RM} vignettes/.build.timestamp

clean-all: clean clean-tar clean-vignettes

install-dependencies install-upstream:
	cd ${PKG} && ${RSCRIPT} ../maker/include/install-dependencies.R

install: | build install-only

install-only:
	${R} CMD INSTALL ${INSTALLARGS} ${TARGZ}

remove:
	${R} CMD REMOVE ${PKG}

roxygen: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKG)"')";

rd: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKG)"', roclets=\"rd\")";

run-demos:
	${RSCRIPT} ./maker/include/run-demos.R

tests:
	${R} -e "library('testthat'); test_package('"${PKG}"')"

win-builder: check
	ncftpput win-builder.r-project.org R-release ${PKGTGZ}

