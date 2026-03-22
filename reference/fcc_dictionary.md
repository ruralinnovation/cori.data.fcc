# Dictionary for our datasets

Currently we are providing, Form 477 (f477) data and National Broadband
Map at the broadband services location (NBM_raw) level or processed at
Census Block (NBM_block)

## Usage

``` r
fcc_dictionary
```

## Format

### `fcc_dictionary`

A data frame with 15 rows and 5 columns:

- dataset:

  name of the dataset

- var_name:

  name of a field/columns

- var_type:

  Data type

- var_description:

  Description either provided by FCC or describing what was our process

- var_example:

  One illustration

## Source

<https://www.fcc.gov/general/explanation-broadband-deployment-data>
