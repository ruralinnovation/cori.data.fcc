SHELL := bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables

# FROM Yihui https://github.com/yihui/knitr/blob/master/Makefile
# he go on parent directory see cd ..;
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)

all: check clean

## build		: build tarbal
build:
	cd ..;\
	R CMD build --no-manual $(PKGSRC)

## check		: check tarbal
check: build
	cd ..;\
	R CMD check $(PKGNAME)_$(PKGVERS).tar.gz

#doc		: build doc 
doc:
	R -e 'devtools::document()'

## article	: test article 
article:
	R -e 'rmarkdown::render("vignettes/articles/f477.Rmd", envir = new.env())'
	open 'vignettes/articles/f477.html'

## clean		: delete pkg tar and Rcheck/
clean:
	$(RM) -r vignettes/articles/*.html	
	cd ..;\
	$(RM) -r $(PKGNAME).Rcheck/;\
	$(RM) -r $(PKGNAME)_$(PKGVERS).tar.gz\
	

## help		: Quick help/reminder
help : Makefile
	@sed -n 's/^##//p' $<