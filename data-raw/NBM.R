## code to prepare `NBM` dataset goes here

library(cori.data.fcc)

dir <- "data_swamp/nbm/"

release <- get_nbm_release()

nbm_data <- get_nbm_available()

system(sprintf("mkdir -p %s", dir))

# this is a big loop
for (i in release$filing_subtype){
  dl_nbm(
    path_to_dl = "data_swamp/nbm",
    release_date = i,
    data_type = "Fixed Broadband",
    data_category = "Nationwide")
}

num_files <- nbm_data |>
  dplyr::filter(data_type == "Fixed Broadband" &
                  data_category == "Nationwide") |>
  nrow()
# echking if we have all the files
files_dl <- length(list.files(dir, pattern = "*.zip"))

stopifnot("we are missing some files" = identical(num_files, files_dl))

system(sprintf("mkdir -p %sraw", dir))

system(sprintf("unzip %s\\*.zip -d %sraw", dir, dir))

system(sprintf("du -sh %sraw", dir))
# 290G    data_swamp/nbm/raw