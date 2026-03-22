# Get a list of release available in FCC NBM

Get a list of release available in FCC NBM

## Usage

``` r
get_nbm_release(
  filing_url = "https://broadbandmap.fcc.gov/nbm/map/api/published/filing"
)
```

## Arguments

- filing_url:

  a string providing NBM filing API. Default is
  "https://broadbandmap.fcc.gov/nbm/map/api/published/filing"

## Value

A data frame.

## Examples

``` r
nbm <- get_nbm_release()
```
