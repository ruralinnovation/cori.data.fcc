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
nbm_data <- get_nbm_available()
head(nbm_data)
#>        id           release       data_type technology_code state_fips
#> 1 1358187 December 31, 2023 Fixed Broadband               0         01
#> 2 1358188 December 31, 2023 Fixed Broadband               0         04
#> 3 1358189 December 31, 2023 Fixed Broadband               0         06
#> 4 1358190 December 31, 2023 Fixed Broadband               0         12
#> 5 1358191 December 31, 2023 Fixed Broadband               0         17
#> 6 1358192 December 31, 2023 Fixed Broadband               0         18
#>   provider_id                                  file_name file_type
#> 1        <NA> bdc_01_Other_fixed_broadband_D23_24dec2025       csv
#> 2        <NA> bdc_04_Other_fixed_broadband_D23_24dec2025       csv
#> 3        <NA> bdc_06_Other_fixed_broadband_D23_24dec2025       csv
#> 4        <NA> bdc_12_Other_fixed_broadband_D23_24dec2025       csv
#> 5        <NA> bdc_17_Other_fixed_broadband_D23_24dec2025       csv
#> 6        <NA> bdc_18_Other_fixed_broadband_D23_24dec2025       csv
#>   data_category
#> 1    Nationwide
#> 2    Nationwide
#> 3    Nationwide
#> 4    Nationwide
#> 5    Nationwide
#> 6    Nationwide
```
