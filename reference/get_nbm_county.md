# Load NBM Broadband Servicable Location (BSL) counts for given Census County from CORI S3 bucket

Get all the data related to a county.

## Usage

``` r
get_nbm_county(
  geoid_co,
  release = c("latest", "D23", "J24", "D24", "J25"),
  data_dir = tempdir()
)
```

## Arguments

- geoid_co:

  a string of 5-digit numbers

- release:

  a string with value "D23", "J24", "D24", "J25" (respectively targeting
  releases from December2023, June2024, December2024, June2025)

- data_dir:

  path to download directory

## Value

a data frame

## Details

A row in this data represent a Census County (2020 vintage).

Data Source: FCC Broadband Data Collection

## Examples

``` r
if (FALSE) { # \dontrun{
  nbm_bl <- get_nbm_county(geoid_co = "47051")
} # }
```
