skip_if_fcc_down <- function() {
  probe_file <- tempfile(fileext = ".json")
  on.exit(unlink(probe_file), add = TRUE)

  res <- tryCatch(
    download_file("https://broadbandmap.fcc.gov/nbm/map/api/published/filing", probe_file),
    error = function(e) e
  )

  ok <- !inherits(res, "error") && file.exists(probe_file) && file.size(probe_file) > 0
  if (!ok) skip("broadbandmap.fcc.gov unreachable")
}
