
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cori.data.fcc

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/ruralinnovation/cori.data.fcc/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ruralinnovation/cori.data.fcc?branch=main)
[![R-CMD-check](https://github.com/ruralinnovation/cori.data.fcc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ruralinnovation/cori.data.fcc/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of cori.data.fcc is to facilate the discovery, the download and
uses of FCC’s data.

It covers:

- National Broadband Map [(NBM)](https://broadbandmap.fcc.gov/home)
  data  
- [Form
  477](https://www.fcc.gov/general/broadband-deployment-data-fcc-form-477)
  data

## Installation

You can install the development version of cori.data.fcc from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ruralinnovation/cori.data.fcc")
```

## Examples

``` r
library(cori.data.fcc)
```

### National Broadband Map

- The package is providing you a way to download zipped `csv` see the
  vignette “Check and download NBM data”

- Access a parquet files stored in CORI s3 bucket per county:

``` r
guilford_cty <- get_county_nbm_raw(geoid_co = "37081")
head(guilford_cty)
#>          frn provider_id brand_name location_id technology
#> 1 0001857952      130077       AT&T  1344960789         10
#> 2 0001857952      130077       AT&T  1344965855         10
#> 3 0001857952      130077       AT&T  1344971572         10
#> 4 0001857952      130077       AT&T  1344982708         10
#> 5 0001857952      130077       AT&T  1344991329         10
#> 6 0001857952      130077       AT&T  1344996969         10
#>   max_advertised_download_speed max_advertised_upload_speed low_latency
#> 1                            10                           1        TRUE
#> 2                             0                           0        TRUE
#> 3                            10                           1        TRUE
#> 4                            50                          10        TRUE
#> 5                            50                          10        TRUE
#> 6                            75                          20        TRUE
#>   business_residential_code state_usps        geoid_bl geoid_co file_time_stamp
#> 1                         X         NC 370810161022008    37081      2024-09-03
#> 2                         X         NC 370810168003003    37081      2024-09-03
#> 3                         X         NC 370810125051020    37081      2024-09-03
#> 4                         X         NC 370810171011021    37081      2024-09-03
#> 5                         X         NC 370810157042006    37081      2024-09-03
#> 6                         X         NC 370810127052022    37081      2024-09-03
#>      release
#> 1 2023-12-01
#> 2 2023-12-01
#> 3 2023-12-01
#> 4 2023-12-01
#> 5 2023-12-01
#> 6 2023-12-01
```

- Use the CORI opinionated version at the Census block level for the
  **last NBM’s release**:

``` r
# get a county
nbm_bl <- get_nbm_bl(geoid_co = "47051")
dim(nbm_bl)
#> [1] 2146   21

# get census block covered by an ISP identified by their FRN
skymesh <- get_frn_nbm_bl("0027136753")
dim(skymesh)
#> [1]  3 21
```

### Form 477

Sadly automating the download of some of the source data is harder for
Form 477. We are not providing that functionality.

You can get all data (multiple years) covering a State from Form 477:

``` r
f477_vt <- get_f477("VT")
head(f477_vt)
#>   Provider_Id        FRN            ProviderName           DBAName
#> 1        9395 0021002092 Stowe Cablevision, Inc. Stowe Access, LLC
#> 2        9395 0021002092 Stowe Cablevision, Inc. Stowe Access, LLC
#> 3        9395 0021002092 Stowe Cablevision, Inc. Stowe Access, LLC
#> 4        9395 0021002092 Stowe Cablevision, Inc. Stowe Access, LLC
#> 5        9395 0021002092 Stowe Cablevision, Inc. Stowe Access, LLC
#> 6        9395 0021002092 Stowe Cablevision, Inc. Stowe Access, LLC
#>        HoldingCompanyName HocoNum               HocoFinal StateAbbr
#> 1 Stowe Cablevision, Inc.  240090 Stowe Cablevision, Inc.        VT
#> 2 Stowe Cablevision, Inc.  240090 Stowe Cablevision, Inc.        VT
#> 3 Stowe Cablevision, Inc.  240090 Stowe Cablevision, Inc.        VT
#> 4 Stowe Cablevision, Inc.  240090 Stowe Cablevision, Inc.        VT
#> 5 Stowe Cablevision, Inc.  240090 Stowe Cablevision, Inc.        VT
#> 6 Stowe Cablevision, Inc.  240090 Stowe Cablevision, Inc.        VT
#>         BlockCode TechCode Consumer MaxAdDown MaxAdUp Business       Date
#> 1 500159531001026       42     TRUE        25       5     TRUE 2014-12-01
#> 2 500159531001026       41     TRUE        25       5     TRUE 2014-12-01
#> 3 500159531001026       50    FALSE         0       0     TRUE 2014-12-01
#> 4 500159531001027       42     TRUE        25       5     TRUE 2014-12-01
#> 5 500159531001027       41     TRUE        25       5     TRUE 2014-12-01
#> 6 500159531001027       50    FALSE         0       0     TRUE 2014-12-01
```

### Utilities

Getting the dictionnary for each dataset:

``` r
head(get_fcc_dictionary())
#>   dataset           var_name var_type
#> 1    f477        Provider_Id     TEXT
#> 2    f477                FRN     TEXT
#> 3    f477       ProviderName  VARCHAR
#> 4    f477            DBAName  VARCHAR
#> 5    f477 HoldingCompanyName  VARCHAR
#> 6    f477            HocoNum     TEXT
#>                               var_description
#> 1             filing number (assigned by FCC)
#> 2                     FCC registration number
#> 3                               Provider name
#> 4                    'Doing business as' name
#> 5 Holding company name (as filed on Form 477)
#> 6    Holding company number (assigned by FCC)
#>                                            var_example
#> 1                                                 8026
#> 2                                           0001570936
#> 3 Arctic Slope Telephone Association Cooperative, Inc.
#> 4                                                ASTAC
#> 5 Arctic Slope Telephone Association Cooperative, Inc.
#> 6                                               130067
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
