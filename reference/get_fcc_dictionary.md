# Display FCC variables and associated descriptions

Return dictionary for a all datasets. Available dataset are "f477",
"nbm_raw" and "nbm_block".

## Usage

``` r
get_fcc_dictionary(dataset = "all")
```

## Arguments

- dataset:

  a string matching a dataset, default is "all"

## Value

a data frame

## Examples

``` r
get_fcc_dictionary("nbm_block")
#>      dataset                                var_name    var_type
#> 30 nbm_block                                geoid_bl VARCHAR(15)
#> 31 nbm_block                                geoid_st  VARCHAR(2)
#> 32 nbm_block                                geoid_co  VARCHAR(5)
#> 33 nbm_block                              state_abbr  VARCHAR(2)
#> 34 nbm_block                     cnt_total_locations     INTEGER
#> 35 nbm_block                      cnt_bead_locations     INTEGER
#> 36 nbm_block                    cnt_copper_locations     INTEGER
#> 37 nbm_block                     cnt_cable_locations     INTEGER
#> 38 nbm_block                     cnt_fiber_locations     INTEGER
#> 39 nbm_block                     cnt_other_locations     INTEGER
#> 40 nbm_block cnt_unlicensed_fixed_wireless_locations     INTEGER
#> 41 nbm_block   cnt_licensed_fixed_wireless_locations     INTEGER
#> 42 nbm_block        cnt_LBR_fixed_wireless_locations     INTEGER
#> 43 nbm_block               cnt_terrestrial_locations     INTEGER
#> 44 nbm_block                                cnt_25_3     INTEGER
#> 45 nbm_block                              cnt_100_20     INTEGER
#> 46 nbm_block                             cnt_100_100     INTEGER
#> 47 nbm_block                        cnt_distcint_frn     INTEGER
#> 48 nbm_block                               array_frn   VARCHAR[]
#> 49 nbm_block                               combo_frn     UBIGINT
#> 50 nbm_block                                 release        DATE
#>                                                                                                                                                  var_description
#> 30                                             15-digit U.S. Census Bureau FIPS code for the census block in which the Broadband Serviceable Location is located
#> 31                                                                                                                         2-digit U.S. Census Bureau for states
#> 32                                                   5-digit U.S. Census Bureau for county, 2 first numbers represent a State and last 3 a county within a state
#> 33                                                  2-character USPS abbreviation for the state/territory in which the Broadband Serviceable Location is located
#> 34                                                                                                                        Count of the total number of locations
#> 35 Count of the locations that are NOT only covered by a satellite or by an unlicensed wireless services and must provide download and upload speed above 0 MBps
#> 36                                                                                                               Count of locations covered by copper technology
#> 37                                                                                                                Count of locations covered by cable technology
#> 38                                                                                                                Count of locations covered by fiber technology
#> 39                                                                                                                Count of locations covered by Other technology
#> 40                                                                                            Count of locations covered by unlicensed fixed wireless technology
#> 41                                                                                              Count of locations covered by licensed fixed wireless technology
#> 42                                                                                Count of locations covered by licensed-by-Rule (LBR) fixed wireless technology
#> 43                                                                                                          Count of locations covered by terrestrial technology
#> 44                                                                  Count of locations covered by greater or equal 25/3 Maximum advertised download/upload speed
#> 45                                                                Count of locations covered by greater or equal 100/20 Maximum advertised download/upload speed
#> 46                                                               Count of locations covered by greater or equal 100/100 Maximum advertised download/upload speed
#> 47                                                              Count the number of ISP represented by their FRN excluding ISP only providing satellite services
#> 48                                                                                                   List of FRN excluding ISP only providing satellite services
#> 49                                                                                                           Hash, using DuckDB hash function of the list of FRN
#> 50                             Availability data vintage in Month letter (J or D for June or December respectively) and 2digit year (i.e. J23) converted as Date
#>                 var_example
#> 30          020130001003033
#> 31                       02
#> 32                    02013
#> 33                       AK
#> 34                       40
#> 35                       39
#> 36                        0
#> 37                        0
#> 38                       39
#> 39                        0
#> 40                        0
#> 41                        0
#> 42                        0
#> 43                       39
#> 44                       39
#> 45                       39
#> 46                        0
#> 47                        1
#> 48 [0004991444, 0018506568]
#> 49     14501455127825752064
#> 50               2023-12-01
```
