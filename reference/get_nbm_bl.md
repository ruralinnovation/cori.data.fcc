# Load NBM BSL counts for given Census Block from CORI S3 bucket

Get all the data related to a block in a county.

## Usage

``` r
get_nbm_bl(
  geoid_co,
  release = c("latest", "D23", "J24", "D24", "J25", "D25"),
  data_dir = tempdir()
)
```

## Arguments

- geoid_co:

  a string of 5-digit numbers

- release:

  a string with value "D23", "J24", "D24", "J25", "D25" (respectively
  targeting releases from December2023, June2024, December24, June2025)

- data_dir:

  path to download directory

## Value

a data frame

## Details

A row in this data represent a census block (2020 vintage). Use
`get_fcc_dictionary("nbm_block")` to get a description of the date.

Data Source: FCC Broadband Data Collection

## Examples

``` r
if (FALSE) { # \dontrun{
  nbm_bl <- get_nbm_bl(geoid_co = "47051")
} # }
```
