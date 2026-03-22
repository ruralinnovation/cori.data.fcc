# Load all BSL from NBM dataset for a specific county

Attention: Depending on the county it can take some times.

## Usage

``` r
get_county_nbm_raw(geoid_co, frn = "all", release = "2024-12-01")
```

## Arguments

- geoid_co:

  a string matching a GEOID for a county

- frn:

  a string of 10 numbers matching FCC's FRN, default is "all"

- release:

  a date, set by default to be '2024-12-01'

## Value

a data frame

## Details

Get all the BSL from NBM dataset for a specific county specified by it's
geoid. A row in this data represent a service per location_id. By
default the function will return all the ISP but a specific FRN and the
last release. (10 number strings, ie "0007435902") can also be used to
be more specific.

Source data: FCC Broadband Funding Map

## Examples

``` r
if (FALSE) { # \dontrun{
 guilford_cty <- get_county_nbm_raw(geoid_co = "37081")
} # }
```
