## Run this script with:
## R CMD BATCH install-packages.r

## Create the personal library if it doesn't exist.
## Ignore a warning if the directory already exists.
dir.create(Sys.getenv("R_LIBS_USER"), showWarnings=FALSE, recursive=TRUE)

## Install jsonlite and optparse packages
install.packages(c("jsonlite", "optparse", "getopt"), Sys.getenv("R_LIBS_USER"), repos="http://cran.case.edu")