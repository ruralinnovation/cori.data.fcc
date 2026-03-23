# Load part of NBM at Census Block from CORI S3 bucket

Get all the data related to a states or county.

Get all the data related to a states or county.

## Usage

``` r
get_nbm_bl(geoid_co, release = "latest")

get_nbm_bl(geoid_co, release = "latest")
```

## Arguments

- geoid_co:

  a string of 5-digit numbers

- release:

  a string with value "D23", "J24", "D24", "J25" (respectively targeting
  releases from December2023, June2024, December24, June2025)

## Value

a data frame

a data frame

## Details

A row in this data represent a census block (2020 vintage). Use
`get_fcc_dictionary("nbm_block")` to get a description of the date.

Data Source: FCC Broadband Data Collection

A row in this data represent a census block (2020 vintage). Use
`get_fcc_dictionary("nbm_block")` to get a description of the date.

Data Source: FCC Broadband Data Collection

## Examples

``` r
if (FALSE) { # \dontrun{
  nbm_bl <- get_nbm_bl(geoid_co = "47051")
} # }
if (FALSE) { # \dontrun{
  nbm_bl <- get_nbm_bl(geoid_co = "47051")
} # }
```
