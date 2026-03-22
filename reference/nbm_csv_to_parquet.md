# Convert CSVs to parquet for NBM data

Draft version of converting a lot of FCC NBM CSVs into a parquet file
system DuckDB is quite greedy on your system (but fast)

## Usage

``` r
nbm_csv_to_parquet(
  parquet_name,
  src_directory = "~/data_swamp/",
  part_one = "state_abbr",
  part_two = "technology"
)
```

## Arguments

- parquet_name:

  a path were the parquet files should be stored

- src_directory:

  a directory containing only the csv needed

- part_one:

  a string defining the first column to partition the parquet file

- part_two:

  a string defining the second column to partition the parquet file

## Value

0 if the execute went well and write a parquet file
