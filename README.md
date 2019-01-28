# rforage: Package to import MedPC raw data files from foraging task into an R data frame

To Install: <br/>
``devtools::install_github("gkane26/rforage")``

Exmaple:<br/>

```
library(rforage)
file = file.choose()
dat = med_to_dt(dat, travel=10, group="DREADD", treatment="CNO")
dat = get_patch_data(dat)
save_file_name = save_forage_data(dat, path="~/Desktop")

# to reload data
load_file_names = c(save_file_name, save_file_name)
reloaded_data = load_forage_data(load_file_names) # can load 1 or multiple files, returns a single data frame
```

See documentation for all options on functions. For example:
``?med_to_dt``
