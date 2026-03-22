# Load part of NBM at Census Block from CORI s3 bucket

Get all the data related to a FRN. A row in this data represent a census
block (2020 vintage).

## Usage

``` r
get_frn_nbm_bl(frn, release = "latest")
```

## Arguments

- frn:

  a string of 10 numbers matching FCC's FRN

- release:

  a string with value "D23", "J24", "D24", "J25" (respectively targeting
  releases from December2023, June2024, December24, June2025)

## Value

a data frame

## Details

IMPORTANT: We are not counting blocks:

- when covered only by satellite servives

- and discarding a location when a service of 0/0 download/uploads
  speeds.

Use `get_fcc_dictionary("nbm_block")` to get a description of the date.
A FRN is a 10 number strings, ie "0007435902" can also be used to be
more specific.

Data Source: FCC Broadband Data Collection

## Examples

``` r
if (FALSE) { # \dontrun{
 skymesh <- get_frn_nbm_bl("0027136753")
} # }
```
