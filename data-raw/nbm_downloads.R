library(cori.data.fcc)

data_dir <- "inst/ext_data/nbm"

source_dir <- paste0(data_dir, "/source")

release <- get_nbm_release()

nbm_data <- get_nbm_available()

system(sprintf("mkdir -p %s", source_dir))

# this is a big loop
for (i in release$filing_subtype){
  dl_nbm(
    path_to_dl = source_dir,
    release_date = i,
    data_type = "Fixed Broadband",
    data_category = "Nationwide")
}
