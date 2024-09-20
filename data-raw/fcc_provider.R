if (!file.exists("data-raw/fcc_provider")) {
  temp <- tempfile(fileext = ".xlsx")
  url <- paste0("https://us-fcc.app.box.com/index.php?",
                "rm=box_download_shared_file&vanity_name=",
                "bdcprovideridtable&file_id=f_968170249571")
  download.file(url, temp, quiet = TRUE)
  fcc_provider <- readxl::read_xlsx(temp)
  unlink(temp)
}

names(fcc_provider) <- c("provider_name", "affiliation",
                         "operation_type", "frn", "provider_id")

fcc_provider <- as.data.frame(fcc_provider)

usethis::use_data(fcc_provider, overwrite = TRUE)
