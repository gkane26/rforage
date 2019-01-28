# rforage: Package to import MedPC raw data files from foraging task into an R data frame

To install, make sure you have the devtools package. If not,: <br/>
``install.packages("devtools")``

Next, install this package directly from github: <br/>
``devtools::install_github("gkane26/rforage")``

#### Instructions for use <br/>

First, get the path to MedPC data files that you would like to import. These can be typed in manually, or selected via a GUI in a number of ways. I think the tcltk package is a good option across platforms. If using a mac, this will require [XQuartz](https://www.xquartz.org/) is installed. Example: <br/>
``files = tcltk::tk_choose.files()``

Next, use the med_to_dt function and get_patch_data function to import the trial-by-trial data from the MedPC file and to add basic variables for each patch (number of presses per patch, how many presses until leaving, time spent in each patch, etc.).
```
library(rforage)
dat = med_to_dt(file[1], travel=10, group="DREADD", treatment="CNO")
dat = get_patch_data(dat)
```

Files can be saved to a csv or Rdata file:
```
save_file_name = save_forage_data(dat, path="~/Desktop", as_csv=F) # for Rdata
save_file_name = save_forage_data(dat, path="~/Desktop", as_csv=T) # for csv
```

And these files can be reloaded for further analysis. Files can be loaded one at a time, or multiple at once into a single data frame by using a vector of filenames: <br/>
```
reloaded_data = load_forage_data(save_file_name) # can load 1 or multiple files, returns a single data frame
reloaded_data = load_forage_data(c(save_file_name, save_file_name)) # loads multiple files, still returns a single data frame
```

To see additional options or for further details, see documentation. For example:
``?med_to_dt``
