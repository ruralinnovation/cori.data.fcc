# cori.data.fcc 0.1.1

## Minor improvements 

* correct typos in data stories Thanks @camdenblatchly

* update with FCC new API request that is needed a referer 

* bring back the changelog that you are reading


# cori.data.fcc 0.1.0

## Major Changes

### New datasets

*  Add NBM Block: CORI opinionated version designed at the Census block level

*  Add NBM raws, past 4 releases

### New functions

* `get_frn_nbm_bl()` allows you to get all block where this FRN reported had services (minus satellite BSL and 0/0 speeds services)

* `get_nbm_bl()`allows you to get all block from one county

* `get_county_nbm_raws()` allows you to get raw NBM data for a specific county and for a release, by default the last one. 

### Updated functions

* update to `get_fcc_dictionary.R` description for new data set ("nbm_block", "nbm_raw") and their fields

### Removed functions

* `fcc_to_parquet()` not needed and/or too opinionated to be useful

# cori.data.fcc 0.0.1

## Major Changes

* Provides way to access Form 477  

* Provides data story on Form 477

* `fcc_dictionary()` to provide description of each fields per data set

## Minor improvements 

* Organize reference of function by themes 


# cori.data.fcc (first release)

* First functions released.

* Improve functions with a user_agent defined in aaa.R #9