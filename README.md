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
