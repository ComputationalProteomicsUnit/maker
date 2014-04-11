# Makefile for R packages

`maker` is based on https://github.com/tudo-r/makeR

We use this *git submodule* to store our central R Makefile that should reduce
the administrative effort.

## Contact

You are welcome to:

* submit suggestions and bug-reports at:
    <https://github.com/ComputationalProteomicsUnit/maker/issues>
* send a pull request on:
    <https://github.com/ComputationalProteomicsUnit/maker/>
* compose an e-mail to: <mail@sebastiangibb.de>

## Integrate maker into your project

    cd my-r-package

    git submodule add git@github.com:ComputationalProteomicsUnit/maker.git
    git submodule init
    git submodule update

    echo "include maker/Makefile" > Makefile

    if [ -f .Rbuildignore ] ; then
      grep "Makefile" .Rbuildignore > /dev/null
      if [ $? -ne 0 ] ; then echo '^Makefile$' >> .Rbuildignore ; fi
      grep "maker" .Rbuildignore > /dev/null
      if [ $? -ne 0 ] ; then echo '^maker$' >> .Rbuildignore ; fi
    else
      echo '^Makefile$' > .Rbuildignore
      echo '^maker$' >> .Rbuildignore
    fi

    git commit -am "use maker scripts"

## Update maker

    cd my-r-package

    cd maker
    git checkout master
    git pull
    cd ..
    git commit -am "update maker scripts"

