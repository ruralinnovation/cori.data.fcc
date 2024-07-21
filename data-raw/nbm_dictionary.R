# goal get a list of all columns per data set in FCC'NBM

library(cori.data.fcc)

data_type <- "Broadband Summary by Geography Type"

# Broadband Summary by Geography Type
dl_nbm(path_to_dl = "data-raw/", release_date = "December 31, 2022",
       data_type = data_type, "Nationwide",
       quiet = TRUE)

ls_files <- list.files("data-raw/", full.names = TRUE, pattern = ".zip$")

unzip(ls_files, exdir = "data-raw/")

bb_sum_geo <- read.csv(list.files("data-raw/",
                                  full.names = TRUE,
                                  pattern = ".csv$"))


names(bb_sum_geo)

# data_type is FCC naming it is kind of confusing because they also use
# Data Type to describe the type of data (string, integer, etc) in a field

nbm_dictionary <- data.frame(data_type = rep(data_type,
                                             length(names(bb_sum_geo))),
                             data_category = "Nationwide",
                             field = names(bb_sum_geo),
                             description = "")

usethis::use_data(nbm_dictionary , overwrite = TRUE)
