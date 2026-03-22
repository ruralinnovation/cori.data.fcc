# Load part of Form 477 estimates data from CORI s3 bucket

Get all the data related to Form 477 for a US State. A row in this data
represent a service per census block (2010 vintage). By default the
function will return all the ISP but a specific FRN (10 number strings,
ie "0007435902") can also be used to be more specific.

## Usage

``` r
get_f477(state_abbr, frn = "all")
```

## Arguments

- state_abbr:

  a string matching State Abbreviation ("NC", "vt")

- frn:

  a string of 10 numbers matching FCC's FRN, default is "all"

## Value

a data frame

## Details

Source data: FCC Form 477

## Examples

``` r
if (FALSE) { # \dontrun{
 NC <- get_f477(state_abbr = "NC")
} # }
```
