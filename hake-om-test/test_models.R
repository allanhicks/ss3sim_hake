## Update the development tools, if you haven't recently
update.packages(c('knitr', 'devtools', 'roxygen2'))
## Build the ss3sim developement package
remove.packages("ss3sim")
devtools::install_github("ss3sim/ss3sim")
library(ss3sim)
library(r4ss)

## I made a copy of the hake-om folder on 7/2/14 so we could test stuff and
## not break the original. Run it to get the initial output files.
file.copy("hakeOM.dat", "hakeOM_original.dat")
system("ss3 -maxfn 1 -nohess")
replist <- SS_output(dir=getwd(), covar=FALSE)
TSCplot(replist)

## See if we can change the fishing effort. First need to update the
## starter file to read form the par file
?change_f
file.copy("ss3.par", "ss3_original.par")
change_f(years=1966:2013, years_alter=1966:2013,
         fvals=c(rep(0, len=18), rep(2, len=30)), file_out="ss3.par")
system("ss3 -maxfn 1 -nohess")
replist <- SS_output(dir=getwd(), covar=FALSE)
TSCplot(replist)

## Recruitment deviations (process error) currently at 0, let's add some
?change_rec_devs
change_rec_devs(2*rnorm(68), file_out="ss3.par")
system("ss3 -maxfn 1 -nohess")
replist <- SS_output(dir=getwd(), covar=FALSE)
TSCplot(replist)
SSplotRecdevs(replist, 1)

## The data inputs
SSplotData(replist)
?change_agecomp
infile <- r4ss::SS_readdat("data.ss_new", section=2, verbose=FALSE)
change_agecomp(infile=infile, outfile="hakeOM.dat", fleets=c(1,2),
               Nsamp=list(50,100), years=list( 1976:1978, c(1995, 1998)))
## No length comps
## Index of abundance
change_index(infile=infile, outfile="hakeOM.dat", fleets=2,
             years=list(c(1995, 1998)), sds_obs=list(c(.1,.2)))
system("ss3 -maxfn 1 -nohess")
replist <- SS_output(dir=getwd(), covar=FALSE)
dev.new()
SSplotData(replist)

## We won't use this option, presumably, but can set retrospective peels
?change_retro
change_retro("starter.ss_new", "retrotest.ss", retro_yr=-3)

?change_e
## We'll use this one extensively, to create trends in growth by year and
## cohort.
?change_tv
