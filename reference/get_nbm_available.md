# Get a list of files availables in FCC servers

NBM's API:

    paste0("https://broadbandmap.fcc.gov/nbm/",
           "map/api/national_map_process/nbm_get_data_download/")

## Usage

``` r
get_nbm_available(
  get_root_url = paste0("https://broadbandmap.fcc.gov/nbm/map/",
    "api/national_map_process/nbm_get_data_download/")
)
```

## Arguments

- get_root_url:

  a string providing NBM filing API.

## Value

A data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
nbm_data <- get_nbm_available()
head(nbm_data)
} # }
```
