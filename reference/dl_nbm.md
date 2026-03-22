# Download NBM data

Function that download all NBM data related to CORI works. It takes a
path to download the zipped csv.

## Usage

``` r
dl_nbm(
  path_to_dl = "~/data_swamp",
  release_date = "June 30, 2023",
  data_type = "Fixed Broadband",
  data_category = "Nationwide",
  ...
)
```

## Arguments

- path_to_dl:

  a string by default "~/data_swamp"

- release_date:

  a string can be "December 31, 2023" or "June 30, 2023"

- data_type:

  a string "Fixed Broadband"

- data_category:

  a string "Nationwide"

- ...:

  additional parameters for download.file()

## Value

Zipped csv

## Examples

``` r
if (FALSE) { # \dontrun{
system("mkdir -p  ~/data_swamp")
dl_nbm(release_date = "June 30, 2023")
} # }
```
