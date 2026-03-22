# Get info on one or nor FRN

Get info on one or nor FRN

## Usage

``` r
check_frn(frn)
```

## Arguments

- frn:

  one or more FCC FRN, it can be a number or a string

## Value

a table with info on FRN

## Examples

``` r
check_frn(8181448)
#>   provider_name affiliation operation_type        frn provider_id
#> 6    1stel, Inc 1stel, Inc.       Non-ILEC 0008181448      190003
```
