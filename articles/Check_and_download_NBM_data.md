# Check and download NBM data

``` r
library(cori.data.fcc)
```

This example shows a basic workflow:

1.  First, you can inspect what releases are available:

``` r
release <- get_nbm_release() # get the available releases
release
```

    ##   filing_type_id filing_type    filing_subtype
    ## 1         100011    Biannual December 31, 2023
    ## 2         100015    Biannual     June 30, 2024
    ## 3         100018    Biannual December 31, 2024
    ##                           process_uuid enable_bfm_link
    ## 1 8033e241-2ab4-4ff6-812e-1efb049fe87f            TRUE
    ## 2 cf58c704-0c76-40fa-845a-f0138ddded0c            TRUE
    ## 3 47e9d20b-5c4e-4c29-a6fa-65cfd2b7f62e            TRUE
    ##   enable_challenge_download
    ## 1                      TRUE
    ## 2                      TRUE
    ## 3                      TRUE

2.  Second, you can check what files are available:

``` r
nbm <- get_nbm_available() # get what data is available

# if we are interested in  "Fixed Broadband" / "Nationwide" / released "June 30, 2023"
nbm_filter <- nbm[which(nbm$release == "June 30, 2023" &
                        nbm$data_type == "Fixed Broadband" &
                        nbm$data_category == "Nationwide"), ]
rownames(nbm_filter) <- NULL


# or
nbm_dplyr_filter <- nbm |> dplyr::filter(release == "June 30, 2023" &
                                         data_type == "Fixed Broadband" &
                                         data_category == "Nationwide")

all.equal(nbm_filter, nbm_dplyr_filter)
```

    ## [1] TRUE

``` r
#> [1] TRUE
head(nbm_filter)
```

    ## [1] id              release         data_type       technology_code
    ## [5] state_fips      provider_id     file_name       file_type      
    ## [9] data_category  
    ## <0 rows> (or 0-length row.names)
