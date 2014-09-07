# More `maker` recipes

To use any of these contributed reciepes, copy the relevant chunks
into your `.makerrc` file or add new targets as described in the
`README.md` file.


<!-- 
### TemplateTitle

``` Makefile
# - - - - -
# Variables
# - - - - -

# - - - - -
# Targets
# - - - - -

```
-->

### Spell check

To check spell we can use `tools::aspell_*` functions. In what follows we
assume aspell to be installed. Main targets are `aspell-rd`,
`aspell-vignette`, `aspell-r` and `aspell-c`: they provide access to
to `aspell_package_Rd_files`, `aspell_package_vignettes`,
`aspell_package_C_files` and `aspell_package_R_files` respectively.
Finally `aspell-all` do all the checks.
A pager is used to display aspell output.

```Makefile
# - - - - -
# Variables
# - - - - -

MAKER_PAGER := less
ASPELL_MASTER_DICT := en_US
ASPELL_EXTRA_DICT := en_GB
ASPELL_COMMAND_PRE := ${R} --vanilla --quiet -e "library(tools); 
ASPELL_COMMAND_POST := ('"$(PKGDIR)"', control = c('--master="$(ASPELL_MASTER_DICT)"', '--add-extra-dicts="$(ASPELL_EXTRA_DICT)"'), dictionaries = Sys.glob(file.path(R.home('share'), 'dictionaries', '*.rds')))" 
ASPELL_RD_FUN := aspell_package_Rd_files
ASPELL_VIGNETTE_FUN := aspell_package_vignettes
ASPELL_C_FUN := aspell_package_C_files
ASPELL_R_FUN := aspell_package_R_files
ASPELL_RD_COMMAND := ${ASPELL_COMMAND_PRE}${ASPELL_RD_FUN}${ASPELL_COMMAND_POST}
ASPELL_VIGNETTE_COMMAND := ${ASPELL_COMMAND_PRE}${ASPELL_VIGNETTE_FUN}${ASPELL_COMMAND_POST}
ASPELL_C_COMMAND := ${ASPELL_COMMAND_PRE}${ASPELL_C_FUN}${ASPELL_COMMAND_POST}
ASPELL_R_COMMAND := ${ASPELL_COMMAND_PRE}${ASPELL_R_FUN}${ASPELL_COMMAND_POST}

# - - - - -
# Targets
# - - - - -

.aspell-rd:
	${ASPELL_RD_COMMAND}
.aspell-vignette: 
	${ASPELL_VIGNETTE_COMMAND}
.aspell-r: 
	${ASPELL_R_COMMAND}
.aspell-c: 
	${ASPELL_C_COMMAND}

aspell-rd: 
	make .aspell-rd | ${MAKER_PAGER}
aspell-vignette: 
	make .aspell-vignette | $(MAKER_PAGER)
aspell-r: 
	make .aspell-r | $(MAKER_PAGER)
aspell-c: 
	make .aspell-c | $(MAKER_PAGER)

aspell-all:
	(make .aspell-rd ; make .aspell-vignette; make .aspell-r; make .aspell-c) | $(MAKER_PAGER)

```


### `codetools` check

`check-codetools` target check the package with `codetools::checkUsage`
too. This implement a check with the most rigorous functions code analysis
(a NOTE is risen, false positive are possible, but can be anyhow useful).
The user can set different options (variable `CODETOOLS_OPTION` to choose
what to check) as a comma separated value pairs (eg 'a=TRUE, b=FALSE', more
info
[here](http://cran.r-project.org/doc/manuals/r-release/R-ints.html#Tools)
and [here](http://stackoverflow.com/questions/10017702/)). By default,
below all checks are performed. If the user set up `~/.R/check.Renviron`
`CODETOOLS_OPTION` is ignored.


``` Makefile
# - - - - -
# Variables
# - - - - -

CODETOOLS_OPTIONS := "all=TRUE"

# - - - - -
# Targets
# - - - - -

check-codetools: 
	export _R_CHECK_CODETOOLS_PROFILE_=$(CODETOOLS_OPTIONS) && make check PKG=$(PKG)

```


### Further documenting targets
devtools::document targets and `clean` option for both
`roxygen::roxygenize` and `devtools::document` 

``` Makefile
# - - - - -
# Targets
# - - - - -

document: clean
	${R} -e "library(devtools); document('"$(PKGDIR)"')";
document-rd: clean
	${R} -e "library(devtools); document('"$(PKGDIR)"', roclets='rd')";
document-clean: clean
	${R} -e "library(devtools); document('"$(PKGDIR)"', clean=TRUE)";
document-rd-clean: clean
	${R} -e "library(devtools); document('"$(PKGDIR)"', roclets='rd', clean=TRUE)";

roxygen-clean: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKGDIR)"', clean=TRUE)";
roxygen-rd-clean: clean
	${R} -e "library(roxygen2); roxygenize('"$(PKGDIR)"', roclets='rd', clean=TRUE)";

```


### Continuous Integration with GitHub
`ci-add-travis` and `ci-add-appveyor` can be useful for adding continuous
integration with [r-travis](https://github.com/craigcitro/r-travis) (unix
building) and [r-appveyor](https://github.com/krlmlr/r-appveyor) (win
building and deployment)

``` Makefile
# - - - - -
# Variables
# - - - - -

GITHUB_USER := yourUsernameHere#

# - - - - -
# Targets
# - - - - -

.travis:
	wget https://raw.githubusercontent.com/craigcitro/r-travis/master/sample.travis.yml -O  $(PKGDIR)/.travis.yml

ci-add-travis: .travis
	echo "[![Build Status](https://travis-ci.org/$(GITHUB_USER)/$(PKG).svg)](https://travis-ci.org/$(GITHUB_USER)/$(PKG))" >> $(PKGDIR)/README.md
	echo '^\.travis\.yml' >> $(PKGDIR)/.Rbuildignore

.appveyor:
	wget https://raw.githubusercontent.com/krlmlr/r-appveyor/master/sample.appveyor.yml -O  $(PKGDIR)/appveyor.yml
	wget https://raw.githubusercontent.com/krlmlr/r-appveyor/master/.gitattributes -O  $(PKGDIR)/.gitattributes

ci-add-appveyor: .appveyor
	echo '^appveyor\.yml' >> $(PKGDIR)/.Rbuildignore
	@ echo ;
	@ echo "   Now you can add a badge to your README.md  " ;
	@ echo "   Go to https://ci.appveyor.com/project/$(GITHUB_USER)/$(PKG)/settings/badges  " ;
	@ echo ;

```
