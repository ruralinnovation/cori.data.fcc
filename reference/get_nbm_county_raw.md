# Load all BSL from NBM dataset for a specific county

Attention: Depending on the county it can take some times.

## Usage

``` r
get_nbm_county_raw(
  geoid_co,
  frn = "all",
  release = "2025-06-01",
  data_dir = tempdir()
)
```

## Arguments

- geoid_co:

  a string matching a GEOID for a county

- frn:

  a string of 10 numbers matching FCC's FRN, default is "all"

- release:

  a date, set by default to be '2025-06-01'

- data_dir:

  path to download directory

## Value

a data frame

## Details

Get all the BSL from NBM dataset for a specific county specified by it's
geoid. A row in this data represent a service per location_id. By
default the function will return all the ISP but a specific FRN and the
last release. (10 number strings, ie "0007435902") can also be used to
be more specific.

Data Source: FCC Broadband Data Collection

## Examples

``` r
if (FALSE) { # \dontrun{
 guilford_cty <- get_nbm_county_raw(geoid_co = "37081")
} # }
```
