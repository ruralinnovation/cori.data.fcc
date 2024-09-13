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

num_files <- nbm_data |> dplyr::filter(release == "June 30, 2023" &
                                       data_type == "Fixed Broadband" &
                                       data_category == "Nationwide") |>
  nrow()

files_dl <- length(list.files(dir, pattern = "*.zip"))

identical(num_files, files_dl)

