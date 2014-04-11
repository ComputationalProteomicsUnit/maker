# ideas and most of the code stolen from https://github.com/tudo-r/makeR
R                  := R --vanilla
RSCRIPT            := Rscript --vanilla
RM                 := rm -rf
RMDIR              := rmdir --ignore-fail-on-non-empty
PACKAGE            := $(shell ${RSCRIPT} ./maker/include/package.R)
VERSION            := $(shell ${RSCRIPT} ./maker/include/version.R)
TARGZ              := ${PACKAGE}_${VERSION}.tar.gz
CHECKARG           := "--as-cran"
INSTALLARG         := "--install-tests"
WARNING_ARE_ERRORS := 1

.PHONEY: build build-vignettes \
	check check-downstream check-reverse-dependencies clean clean-all clean-tar help \
	increment-version-major increment-version-minor increment-version-patch \
	install install-dependencies install-upstream remove roxygen run-demos \
	targets test usage win-builder

help targets usage:
	@echo "Available targets:"
	@echo ""
	@echo " build                       - build source package"
	@echo " build-vignettes             - build vignettes"
	@echo " check                       - check package"
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
	@echo " install                     - install package"
	@echo " install-dependencies        - install package dependencies"
	@echo " install-upstream            - install package dependencies"
	@echo " remove                      - remove package"
	@echo " run-demos                   - source and run demo/*.R files"
	@echo " targets                     - show this usage output"
	@echo " test                        - run unit tests"
	@echo " usage                       - show this usage output"
	@echo " win-builder                 - build package and send to win-builder.r-project.org"

build:
	cd .. && ${R} CMD build	${PACKAGE}

build-vignettes:
	${RSCRIPT} ./maker/include/build-vignettes.R

check: build
	cd .. && ${R} CMD check ${CHECKARG} ${TARGZ} && \
		grep "WARNING" ${PACKAGE}.Rcheck/00check.log > /dev/null ; \
		if [ $$? -eq 0 ] ; then exit ${WARNING_ARE_ERRORS}; fi

check-reverse-dependencies check-downstream: install
	${RSCRIPT} ./maker/include/check-reverse-dependencies.R

clean:
	${RM} src/*.o src/*.so
	${RM} ${PACKAGE}.Rcheck

clean-tar:
	${RM} ${TARGZ}

clean-vignettes:
	${RSCRIPT} ./maker/include/clean-vignettes.R
	${RMDIR} inst/doc

clean-all: clean clean-tar clean-vignettes

increment-version-major:
	${RSCRIPT} ./maker/include/increment-version.R major

increment-version-minor:
	${RSCRIPT} ./maker/include/increment-version.R minor

increment-version-patch:
	${RSCRIPT} ./maker/include/increment-version.R patch

install-dependencies install-upstream:
	${RSCRIPT} ./maker/include/install-dependencies.R

install: build
	cd .. && ${R} CMD INSTALL ${INSTALLARG} ${TARGZ}

remove:
	${R} CMD REMOVE ${PACKAGE}

roxygen: clean
	${RSCRIPT} ./maker/include/roxygen.R

run-demos:
	${RSCRIPT} ./maker/include/run-demos.R

test:
	${RSCRIPT} ./maker/include/test.R

win-builder:
	${RSCRIPT} ./maker/include/win-builder.R

