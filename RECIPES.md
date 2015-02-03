# More `maker` recipes

To use any of these contributed recipes, copy the relevant chunks
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

We can use `tools::aspell_*` functions; in what follows we assume
[aspell](http://aspell.net) to be installed. 

Main targets are `aspell-rd`, `aspell-vignette`, `aspell-r` and `aspell-c`:
they provide access to `aspell_package_Rd_files`,
`aspell_package_vignettes`, `aspell_package_R_files` and
`aspell_package_C_files`  respectively.  A pager is used to display aspell
output.

Finally `aspell-all` does all the checks.  

```Makefile
# - - - - -
# Variables
# - - - - -

MAKER_PAGER := less
ASPELL_MASTER_DICT := en_US
ASPELL_EXTRA_DICT := en_GB
ASPELL_COMMAND_PRE := ${R} --vanilla --quiet -e "library(tools); 
ASPELL_COMMAND_POST := ('"$(PKG)"', control = c('--master="$(ASPELL_MASTER_DICT)"', '--add-extra-dicts="$(ASPELL_EXTRA_DICT)"'), dictionaries = Sys.glob(file.path(R.home('share'), 'dictionaries', '*.rds')))" 
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

`check-codetools` target checks the package with `codetools::checkUsage`
too. It's a check with the most rigorous functions code analysis
(a NOTE is risen, false positive are possible, but can be anyhow useful).

The user can set different options (variable `CODETOOLS_OPTION`) to choose
what to check as a comma separated value pairs (eg `a=TRUE, b=FALSE`, more
info
[here](http://cran.r-project.org/doc/manuals/r-release/R-ints.html#Tools)
and [here](http://stackoverflow.com/questions/10017702/)).

By default, below all checks are performed. If the user set up
`~/.R/check.Renviron` `CODETOOLS_OPTION` is ignored.


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

### Lint with `lintr`
lintr checks adherence to a given style, syntax errors and possible semantic issues

``` Makefile
# - - - - -
# Variables
# - - - - -
# linters are passed as a list of functions; see ?linters for a
# full list of default and available linters. Below (eg, my settings) i use
# the default linters without object_camel_case_linter  

# > names(default_linters) # (as of 2015-01-22)
#  [1] "assignment_linter"              "single_quotes_linter"
#  [3] "absolute_paths_linter"          "no_tab_linter"
#  [5] "line_length_linter"             "commas_linter"
#  [7] "infix_spaces_linter"            "spaces_left_parentheses_linter"
#  [9] "spaces_inside_linter"           "open_curly_linter"
# [11] "closed_curly_linter"            "object_camel_case_linter"
# [13] "object_multiple_dots_linter"    "object_length_linter"
# [15] "object_usage_linter"            "trailing_whitespace_linter"
# [17] "trailing_blank_lines_linter"

LINTR_LINTERS = default_linters[-12]

# - - - - -
# Targets
# - - - - -

lint:
	${R} -e "library(lintr); lint_package('"$(PKGDIR)"', linters = $(LINTR_LINTERS), relative_path = FALSE)"

```


### Coverage report with `covr`

``` Makefile

# - - - - -
# Targets
# - - - - -
covr:
        ${R} -e "library(covr); package_coverage('"$(PKGDIR)"')"

```



### Further documenting targets

`devtools::document` targets and `clean` option for both
`roxygen::roxygenize` and `devtools::document`.

``` Makefile
# - - - - -
# Targets
# - - - - -

document: clean
	${R} -e "library(devtools); document('"$(PKG)"')";
document-rd: clean
	${R} -e "library(devtools); document('"$(PKG)"', roclets='rd')";

```


### Continuous Integration with GitHub

`ci-add-travis` and `ci-add-appveyor` can be useful for adding continuous
integration with [r-travis](https://github.com/craigcitro/r-travis) and
[r-appveyor](https://github.com/krlmlr/r-appveyor).

``` Makefile
# - - - - -
# Variables
# - - - - -

GITHUB_USER := yourUsernameHere#

# - - - - -
# Targets
# - - - - -

.travis:
	wget https://raw.githubusercontent.com/craigcitro/r-travis/master/sample.travis.yml -O  $(PKG)/.travis.yml

ci-add-travis: .travis
	echo "[![Build Status](https://travis-ci.org/$(GITHUB_USER)/$(PKG).svg)](https://travis-ci.org/$(GITHUB_USER)/$(PKG))" >> $(PKG)/README.md
	echo '^\.travis\.yml' >> $(PKG)/.Rbuildignore

.appveyor:
	wget https://raw.githubusercontent.com/krlmlr/r-appveyor/master/sample.appveyor.yml -O  $(PKG)/appveyor.yml
	wget https://raw.githubusercontent.com/krlmlr/r-appveyor/master/.gitattributes -O  $(PKG)/.gitattributes

ci-add-appveyor: .appveyor
	echo '^appveyor\.yml' >> $(PKG)/.Rbuildignore
	@ echo ;
	@ echo "   Now you can add a badge to your README.md  " ;
	@ echo "   Go to https://ci.appveyor.com/project/$(GITHUB_USER)/$(PKG)/settings/badges  " ;
	@ echo ;

```
