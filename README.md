
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cori.data.fcc

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/ruralinnovation/cori.data.fcc/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ruralinnovation/cori.data.fcc?branch=main)
[![R-CMD-check](https://github.com/ruralinnovation/cori.data.fcc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ruralinnovation/cori.data.fcc/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of cori.data.fcc is to facilate the discovery, the download and
the use of FCC’s National Broadband Map
[(NBM)](https://broadbandmap.fcc.gov/home) data.

## Installation

You can install the development version of cori.data.fcc from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ruralinnovation/cori.data.fcc")
```

## Example

This is a basic example which shows some basic workflow:

``` r
library(cori.data.fcc)

release <- get_nbm_release() # get the available releases
release
#>   filing_type_id filing_type    filing_subtype
#> 1         100006    Biannual December 31, 2022
#> 2         100000    Biannual     June 30, 2022
#> 3         100011    Biannual December 31, 2023
#> 4         100007    Biannual     June 30, 2023
#>                           process_uuid enable_bfm_link
#> 1 bbfba324-616d-4247-ab49-933fdd97ff12            TRUE
#> 2 7b81911a-c0cb-4be6-8e6c-63a32e8bf917            TRUE
#> 3 22fad384-b07c-4037-ae8c-58c9f6bbf2c4            TRUE
#> 4 09b52db9-5dab-4414-baa9-3834034be045            TRUE
#>   enable_challenge_download
#> 1                      TRUE
#> 2                      TRUE
#> 3                      TRUE
#> 4                      TRUE
```

You can also inspect what is available:

``` r
nbm <- get_nbm_available() # get what data is available
# if we are intrested in  "Fixed Broadband" / "Nationwide" / released "June 30, 2023"
nbm_filter <- nbm[which(nbm$release == "June 30, 2023" &
                        nbm$data_type == "Fixed Broadband" &
                        nbm$data_category == "Nationwide"), ]
rownames(nbm_filter) <- NULL


# or
nbm_dplyr_filter <- nbm |> dplyr::filter(release == "June 30, 2023" &
                                         data_type == "Fixed Broadband" &
                                         data_category == "Nationwide")
all.equal(nbm_filter, nbm_dplyr_filter)
#> [1] TRUE
head(nbm_filter)
#>       id       release       data_type technology_code state_fips provider_id
#> 1 628517 June 30, 2023 Fixed Broadband               0         01        <NA>
#> 2 628518 June 30, 2023 Fixed Broadband               0         04        <NA>
#> 3 628519 June 30, 2023 Fixed Broadband               0         06        <NA>
#> 4 628520 June 30, 2023 Fixed Broadband               0         12        <NA>
#> 5 628521 June 30, 2023 Fixed Broadband               0         17        <NA>
#> 6 628522 June 30, 2023 Fixed Broadband               0         18        <NA>
#>                                    file_name file_type data_category
#> 1 bdc_01_Other_fixed_broadband_J23_01jul2024       csv    Nationwide
#> 2 bdc_04_Other_fixed_broadband_J23_01jul2024       csv    Nationwide
#> 3 bdc_06_Other_fixed_broadband_J23_01jul2024       csv    Nationwide
#> 4 bdc_12_Other_fixed_broadband_J23_01jul2024       csv    Nationwide
#> 5 bdc_17_Other_fixed_broadband_J23_01jul2024       csv    Nationwide
#> 6 bdc_18_Other_fixed_broadband_J23_01jul2024       csv    Nationwide
```

The package also provide the list of Provider ID and FRN

``` r
str(fcc_provider)
#> 'data.frame':    4456 obs. of  5 variables:
#>  $ provider_name : chr  "@Link Services, LLC" "1 Point Communications" "101Netlink" "123.Net, Inc" ...
#>  $ affiliation   : chr  "AtLink Services, LLC" "1 Point Communications" "101Netlink" "123.Net, Inc." ...
#>  $ operation_type: chr  "Non-ILEC" "Non-ILEC" "Non-ILEC" "Non-ILEC" ...
#>  $ frn           : chr  "0016085920" "0021352968" "0018247254" "0008590846" ...
#>  $ provider_id   : num  290004 270002 190002 460000 490000 ...
```

## Inspiration

This package was imspired by <https://github.com/bbcommons/bfm-explorer>
