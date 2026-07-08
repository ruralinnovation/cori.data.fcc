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
    ## 1         100058    Biannual December 31, 2025
    ## 2         100055    Biannual     June 30, 2025
    ## 3         100015    Biannual     June 30, 2024
    ## 4         100018    Biannual December 31, 2024
    ##                           process_uuid enable_bfm_link
    ## 1 8c672e4b-9442-44ee-8da7-3f352fc8d946            TRUE
    ## 2 dff14441-3733-431c-9aa5-45f3fc6f3a8f            TRUE
    ## 3 1d2b790d-11bc-42b6-b9e0-db7fae757006            TRUE
    ## 4 89fb08b0-999e-4aa2-b9d1-da66de338795            TRUE
    ##   enable_challenge_download
    ## 1                      TRUE
    ## 2                      TRUE
    ## 3                      TRUE
    ## 4                      TRUE

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
