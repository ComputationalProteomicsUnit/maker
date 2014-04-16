## ideas and most of the code stolen from https://github.com/tudo-r/makeR
## updated to be run outside of the package directory 

setvars:
ifeq (${R_HOME},)
R_HOME= $(shell R RHOME)
endif


R                  := "$(R_HOME)/bin/R" --vanilla
RSCRIPT            := Rscript --vanilla
RM                 := rm -rf
RMDIR              := rmdir --ignore-fail-on-non-empty
PACKAGE            := "maker" ## default package
VERSION            := $(shell grep Version ${PACKAGE}/DESCRIPTION | sed -e 's/Version: //')
TARGZ              := ${PACKAGE}_${VERSION}.tar.gz
CHECKARGS          := --no-build-vignettes ## "--as-cran"
INSTALLARGS        := --install-tests
WARNING_ARE_ERRORS := 1
VIGNETTES          := 1
CRAN               := 0


ifeq (${VIGNETTES},0)
BUILDARGS=--no-build-vignettes
endif

ifeq (${CRAN},1)
CHECKARGS += --as-cran
endif


.PHONEY: build vignettes check check-downstream				\
	check-reverse-dependencies clean clean-all clean-tar help	\
	install install-dependencies install-upstream remove roxygen	\
	rd run-demos targets tests usage win-builder

help targets usage:
	@echo "Available targets:"
	@echo ""
	@echo " build                       - build source package"
	@echo " vignettes                   - build vignettes in ./${PACKAGE}/vignettes"
	@echo " check                       - check package"
	@echo " check-downstream            - check packages which depend on this package"
	@echo " check-reverse-dependencies  - check packages which depend on this package"
	@echo " clean                       - remove temporary files and .Rcheck"
	@echo " clean-tar                   - remove .tar.gz archive"
	@echo " clean-vignettes             - remove vignettes in inst/doc/"
	@echo " clean-all                   - combine \"clean\" and \"clean-all\""
	@echo " help                        - show this usage output"
	@echo " install                     - install package"
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

build:
	${R} CMD build ${BUILDARGS} ${PACKAGE}

vignettes:
	cd ${PACKAGE}/vignettes/ && \
	for v in `ls *Rnw`; do \
		${R} CMD Sweave --engine=knitr::knitr --pdf $$v; \
	done


check: build
	${R} CMD check ${CHECKARGS} ${TARGZ} && \
	grep "WARNING" ${PACKAGE}.Rcheck/00check.log > /dev/null ; \
	if [ $$? -eq 0 ] ; then exit ${WARNING_ARE_ERRORS}; fi

check-reverse-dependencies check-downstream: install
	cd ${PACKAGE} && ${RSCRIPT} ./maker/include/check-reverse-dependencies.R

clean:
	${RM} src/*.o src/*.so
	${RM} ${PACKAGE}.Rcheck
	find . -name '.Rhistory' -exec rm '{}' \;
	rm -f *~

clean-tar:
	${RM} ${TARGZ}

clean-vignettes:
	${RSCRIPT} ./maker/include/clean-vignettes.R
	${RMDIR} inst/doc

clean-all: clean clean-tar clean-vignettes

install-dependencies install-upstream:
	cd ${PACKAGE} && ${RSCRIPT} ../maker/include/install-dependencies.R

install: build
	${R} CMD INSTALL ${INSTALLARGS} ${TARGZ}

remove:
	${R} CMD REMOVE ${PACKAGE}

roxygen: clean
	${R} -e "library(roxygen2); roxygenize('"$(PACKAGE)"')";

rd: clean
	${R} -e "library(roxygen2); roxygenize('"$(PACKAGE)"', roclets=\"rd\")";

run-demos:
	${RSCRIPT} ./maker/include/run-demos.R

tests:
	${R} -e "library('testthat'); test_package('"${PACKAGE}"')"

win-builder: check
	ncftpput win-builder.r-project.org R-release ${PKGTGZ}


