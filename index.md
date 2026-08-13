# cori.data.fcc

The goal of `cori.data.fcc` is to facilitate the discovery, analysis,
and use of FCC public data releases.

The package provides access to data from the following sources:

- National Broadband Map [(NBM)](https://broadbandmap.fcc.gov/home)
  data[^1]
- [Form
  477](https://www.fcc.gov/general/broadband-deployment-data-fcc-form-477)
  data

## Installation

You can install the development version of `cori.data.fcc` from
[GitHub](https://github.com/) with:

``` r

# install.packages("remotes")
remotes::install_github("ruralinnovation/cori.data.fcc")
```

## Examples

``` r

library(cori.data.fcc)
```

### National Broadband Map

Key uses:

- Access parquet files stored in a CORI s3 bucket, by county:

``` r

guilford_cty <- get_nbm_county_raw(geoid_co = "37081")
#> [1] "Downloading raw NBM data for NC to specified dir (or temp_dir)..."
dplyr::glimpse(guilford_cty)
#> Rows: 1,427,284
#> Columns: 14
```

| Column                          | Type | Example           |
|---------------------------------|------|-------------------|
| `frn`                           | chr  | “0001857952”      |
| `provider_id`                   | chr  | “130077”          |
| `brand_name`                    | chr  | “AT&T”            |
| `location_id`                   | chr  | “1344957580”      |
| `max_advertised_download_speed` | int  | 75                |
| `max_advertised_upload_speed`   | int  | 20                |
| `low_latency`                   | lgl  | TRUE              |
| `business_residential_code`     | chr  | “X”               |
| `geoid_bl`                      | chr  | “370810160062003” |
| `geoid_co`                      | chr  | “37081”           |
| `file_time_stamp`               | date | 2026-04-29        |
| `release`                       | date | 2025-06-01        |
| `state_usps`                    | chr  | “NC”              |
| `technology`                    | dbl  | 10                |

- Access a CORI-opinionated, Census-block level version of the **latest
  NBM release**:

``` r

# get a county
nbm_bl <- get_nbm_bl(geoid_co = "47051")
#> [1] "Downloading NBM data for TN to specified dir (or temp_dir)..."
dplyr::glimpse(nbm_bl)
#> Rows: 2,146
#> Columns: 21
```

| Column                                    | Type | Example           |
|-------------------------------------------|------|-------------------|
| `geoid_bl`                                | chr  | “470519601001000” |
| `geoid_st`                                | chr  | “47”              |
| `geoid_co`                                | chr  | “47051”           |
| `cnt_total_locations`                     | int  | 5                 |
| `cnt_bead_locations`                      | int  | 0                 |
| `cnt_copper_locations`                    | int  | 0                 |
| `cnt_cable_locations`                     | int  | 0                 |
| `cnt_fiber_locations`                     | int  | 0                 |
| `cnt_other_locations`                     | int  | 0                 |
| `cnt_unlicensed_fixed_wireless_locations` | int  | 4                 |
| `cnt_licensed_fixed_wireless_locations`   | int  | 0                 |
| `cnt_LBR_fixed_wireless_locations`        | int  | 0                 |
| `cnt_terrestrial_locations`               | int  | 0                 |
| `cnt_25_3`                                | int  | 0                 |
| `cnt_100_20`                              | int  | 0                 |
| `cnt_100_100`                             | int  | 0                 |
| `cnt_distcint_frn`                        | int  | 1                 |
| `array_frn`                               | list | NULL              |
| `combo_frn`                               | dbl  | 1.xxx             |
| `release`                                 | date | 2025-12-01        |
| `state_abbr`                              | chr  | “TN”              |

``` r

# get census block covered by an ISP identified by their FRN
skymesh <- get_frn_nbm_bl("0027136753")
dplyr::glimpse(skymesh)
#> Rows: 12
#> Columns: 21
```

| Column | Type | Example |
|----|----|----|
| `geoid_bl` | chr | “391093401001009” |
| `geoid_st` | chr | “39” |
| `geoid_co` | chr | “39109” |
| `cnt_total_locations` | int | 4 |
| `cnt_bead_locations` | int | 4 |
| `cnt_copper_locations` | int | 3 |
| `cnt_cable_locations` | int | 4 |
| `cnt_fiber_locations` | int | 2 |
| `cnt_other_locations` | int | 0 |
| `cnt_unlicensed_fixed_wireless_locations` | int | 4 |
| `cnt_licensed_fixed_wireless_locations` | int | 3 |
| `cnt_LBR_fixed_wireless_locations` | int | 0 |
| `cnt_terrestrial_locations` | int | 4 |
| `cnt_25_3` | int | 4 |
| `cnt_100_20` | int | 4 |
| `cnt_100_100` | int | 3 |
| `cnt_distcint_frn` | int | 4 |
| `array_frn` | list | \<“0018506568”, “0025646373”, …\> |
| `combo_frn` | dbl | 8.639537e+18 |
| `release` | date | 2025-12-01 |
| `state_abbr` | chr | “OH” |

### Form 477

Access state data for multiple years:

``` r

f477_vt <- get_f477("VT")
dplyr::glimpse(f477_vt)
#> Rows: 2,753,817
#> Columns: 15
```

| Column               | Type | Example                       |
|----------------------|------|-------------------------------|
| `Provider_Id`        | chr  | “7095”                        |
| `FRN`                | chr  | “0017631540”                  |
| `ProviderName`       | chr  | “Kingdom Connection”          |
| `DBAName`            | chr  | “Kingdom Connection”          |
| `HoldingCompanyName` | chr  | “Merrill Information Systems” |
| `HocoNum`            | chr  | “130808”                      |
| `HocoFinal`          | chr  | “Merrill Information Systems” |
| `BlockCode`          | chr  | “500059570001002”             |
| `TechCode`           | chr  | “70”                          |
| `Consumer`           | lgl  | TRUE                          |
| `MaxAdDown`          | dbl  | 2                             |
| `MaxAdUp`            | dbl  | 2                             |
| `Business`           | lgl  | TRUE                          |
| `Date`               | date | 2014-12-01                    |
| `StateAbbr`          | chr  | “VT”                          |

### Utilities

Access the dictionary for each dataset:

``` r

dplyr::glimpse(get_fcc_dictionary())
#> Rows: 50
#> Columns: 5
```

| Column            | Type | Example                           |
|-------------------|------|-----------------------------------|
| `dataset`         | chr  | “f477”                            |
| `var_name`        | chr  | “Provider_Id”                     |
| `var_type`        | chr  | “TEXT”                            |
| `var_description` | chr  | “filing number (assigned by FCC)” |
| `var_example`     | chr  | “8026”                            |

The package also provides a list of Provider IDs and FRNs.

``` r

str(fcc_provider)
#> 'data.frame':    4456 obs. of  5 variables:
```

| Column           | Type | Example                |
|------------------|------|------------------------|
| `provider_name`  | chr  | “@Link Services, LLC”  |
| `affiliation`    | chr  | “AtLink Services, LLC” |
| `operation_type` | chr  | “Non-ILEC”             |
| `frn`            | chr  | “0016085920”           |
| `provider_id`    | num  | 290004                 |

## Incorporating the BDC Public Data API

The FCC’s National Broadband Map exposes a public REST API (documented
at <https://us-fcc.app.box.com/v/bdc-public-data-api-swagger>) that
offers a more structured alternative to the bulk download workflow
currently implemented in `data-raw/`. Three endpoints are directly
relevant to the ingestion pipeline.

`GET /api/public/map/listAsOfDates` returns every available release date
for both availability and challenge data types. This is a programmatic
replacement for
[`get_nbm_release()`](https://ruralinnovation.github.io/cori.data.fcc/reference/get_nbm_release.md),
which currently scrapes a separate filing endpoint.

`GET /api/public/map/downloads/listAvailabilityData/{as_of_date}`
returns a full manifest for a given release — including a stable numeric
`file_id`, `file_name`, `record_count`, `state_fips`, `provider_id`, and
category metadata for every downloadable file. This replaces
[`get_nbm_available()`](https://ruralinnovation.github.io/cori.data.fcc/reference/get_nbm_available.md)
and, crucially, provides the information currently reconstructed by hand
from inconsistent FCC filename patterns (the 100-line normalization
block in `data-raw/nbm_raw.R` that repairs `December20ec_`, `June20un_`,
and abbreviated date codes like `D22`/`J23`).

`GET /api/public/map/downloads/downloadFile/availability/{file_id}/1`
downloads a file by its stable numeric ID rather than by a constructed
URL. Combined with the manifest’s `as_of_date` field, the release date
embedded in the DuckDB `strptime(split_part(filename, '_', 7), '%B%Y')`
expression could simply be passed in directly, eliminating all
filename-based date parsing.

The manifest’s `record_count` field also enables a more meaningful
post-download validation than the current file-presence check: row
counts loaded into DuckDB can be compared against the API’s declared
counts before committing a partition. Because the manifest is
date-scoped, comparing it against already-ingested parquet partitions
makes incremental ingestion (downloading only new releases)
straightforward to implement.

All API endpoints require a `username` and `hash_value` request header.
The token is generated once via the NBM web interface at
<https://broadbandmap.fcc.gov/login> under Manage API Access, and the
recommended approach for storing it in R is `keyring`. The
`fcc_provider` table (currently fetched from a hardcoded Box URL in
`data-raw/fcc_provider.R`) is not exposed through the BDC API and would
remain unchanged.

## Inspiration

This package was inspired by <https://github.com/bbcommons/bfm-explorer>

## DuckDB httpfs Configuration — Changelog and Notes

### Background: SSL error with dot-named S3 buckets

In late 2025, the `duckdb` R package began producing SSL certificate
errors when reading parquet files from S3 buckets whose names contain
dots (e.g., `cori.data.bds`). The root cause is a hostname mismatch:
AWS’s virtual-hosted URL style turns `cori.data.bds` into the subdomain
`cori.data.bds.s3.us-east-1.amazonaws.com`, which has too many labels
for AWS’s wildcard TLS certificate (`*.s3.us-east-1.amazonaws.com`
covers only one subdomain level). The error surfaced as:

``` R
SSL peer certificate or SSH remote key was not OK error for HTTP GET to
'https://cori.data.bds.s3.us-east-1.amazonaws.com/...'
```

The fix is one DuckDB setting that switches URL construction from
virtual-hosted style to path style, routing requests as
`https://s3.us-east-1.amazonaws.com/<bucket>/...` instead:

``` r

DBI::dbExecute(con, "SET s3_url_style = 'path';")
```

Although `cori.data.fcc` (no dots in the bucket name) was not directly
affected by this SSL error, the same setting was applied across all
functions in this package for consistency with the rest of the
coriverse.

### Background: HTTP timeout failures in DuckDB 1.4.4+

After applying the SSL fix, a new class of errors appeared in the test
suite for functions that query S3 directly via DuckDB’s httpfs extension
(primarily `get_frn_nbm_bl`, which scans all state-level parquet
partitions to find rows matching a given FRN):

``` R
IO Error: Timeout was reached error for HTTP GET to
'https://s3.us-east-1.amazonaws.com/cori.data.fcc/nbm_block-J24/state_abbr=AR/data_0.parquet'
```

The `http_timeout` setting defaults to 30 seconds and applies per HTTP
request, not per query. Reading a single large state parquet file from
S3 requires multiple HTTP range requests (footer metadata, then
individual row groups), and with DuckDB 1.4.4 the behaviour of the
built-in `httplib` HTTP client changed in ways that increased
per-request latency — particularly documented in duckdb/duckdb-java#548
(<https://github.com/duckdb/duckdb-java/issues/548>). Additionally,
`httpfs_connection_caching` defaults to `false`, meaning every range
request opens a fresh TCP + TLS connection to
`s3.us-east-1.amazonaws.com` rather than reusing an already-negotiated
session.

### Changes applied to all httpfs connections in this package

Three settings are now explicitly configured on every DuckDB connection
that uses the httpfs extension:

``` r

DBI::dbExecute(con, "SET httpfs_client_implementation = 'curl';")
DBI::dbExecute(con, "SET http_timeout = 120;")
DBI::dbExecute(con, "SET httpfs_connection_caching = true;")
```

`httpfs_client_implementation = 'curl'` switches DuckDB from its
built-in `httplib` implementation to libcurl, which has a different and
in this case more reliable code path for S3 range requests. The system
`curl` binary was already being used successfully elsewhere in this
package (in `download_file`) so the underlying library is known to work
in this network environment.

`http_timeout = 120` gives each individual HTTP range request up to 120
seconds before timing out, up from the 30-second default. This is a
backstop for genuinely slow responses rather than a fix on its own.

`httpfs_connection_caching = true` enables connection pooling, so
sequential range requests to the same S3 host reuse an
already-established TLS session. Without this, each of the 100+ HTTP
range requests across a full state partition scan incurs a full TCP
handshake and TLS negotiation, adding hundreds of milliseconds of
overhead per request.

## Handling `broadbandmap.fcc.gov` Outages in Tests

[`get_nbm_release()`](https://ruralinnovation.github.io/cori.data.fcc/reference/get_nbm_release.md)
and
[`get_nbm_available()`](https://ruralinnovation.github.io/cori.data.fcc/reference/get_nbm_available.md)
both call live endpoints on `broadbandmap.fcc.gov`. When that host is
unreachable — including during the Akamai-fronted outage observed in
August 2026 — the functions fail with a curl exit code 92 (HTTP/2 stream
reset) or simply hang on HTTP/1.1.

### Same host, same edge — both old and BDC API paths are affected

An important constraint: both the legacy map API paths and the BDC
Public Data API paths are served from the same host behind the same
Akamai CDN edge:

- Legacy: `https://broadbandmap.fcc.gov/nbm/map/api/published/filing`
- BDC API: `https://broadbandmap.fcc.gov/api/public/map/listAsOfDates`

When the Akamai edge cannot reach the FCC origin, it resets HTTP/2
streams with `INTERNAL_ERROR` on all paths simultaneously. Switching
from the legacy endpoint to the BDC API endpoint does not mitigate a
host-level outage because both resolve to the same Akamai IP, go through
the same TLS termination, and fail identically when the backend is
unavailable. (TCP connects, TLS succeeds, ALPN negotiates `h2` — the
failure happens at the HTTP layer when the edge tries and fails to reach
the FCC origin.)

### Recommended fix: skip tests when the host is unreachable

The tests already use `skip_on_cran()` and `skip_on_ci()`, but have no
guard against external service outages. A lightweight helper resolves
this:

``` r

skip_if_fcc_down <- function() {
  ok <- tryCatch({
    system2("curl", c("--silent", "--max-time", "5", "--head",
                      "https://broadbandmap.fcc.gov/"),
            stdout = FALSE, stderr = FALSE) == 0
  }, error = function(e) FALSE)
  if (!ok) skip("broadbandmap.fcc.gov unreachable")
}
```

Each affected test adds one line:

``` r

test_that("get_nbm_release return a data frame", {
  skip_on_cran()
  skip_on_ci()
  skip_if_fcc_down()
  expect_equal(isTRUE(is.data.frame(get_nbm_release())), TRUE)
})
```

This converts a hard `FAIL` into a `SKIP` whenever the service is down —
the correct outcome for a test whose failure reflects an external
dependency, not a code defect. The BDC API migration (replacing the
legacy endpoints with `listAsOfDates` and `listAvailabilityData`)
remains worthwhile for long-term stability, but does not eliminate the
need for this guard, since both endpoint families share the same host.

### Why queries are still slower than they were in mid-2025

Even with the above settings applied, S3 queries via httpfs are
noticeably slower than they were roughly six months prior. There are
several likely contributing factors. DuckDB’s httpfs extension has been
updated repeatedly across the v1.4 and v1.5 release series (bumped in
v1.5.2 and v1.5.3 release notes), and the default HTTP client
implementation has changed in ways that affect connection setup and
range request behaviour. The BDC data releases themselves have grown —
D25 parquet files are larger than J24 files as FCC adds more reported
locations each cycle — which directly increases the amount of data
DuckDB must read per state partition. Finally, `get_frn_nbm_bl` performs
a full scan across all 57 state and territory partitions
(`s3://cori.data.fcc/nbm_block-{release}/*/*.parquet`) because FRN does
not map to a partition key, so every new row of data added to any
partition adds incremental cost to every call. The local-cache pattern
used by `get_nbm_bl` and `get_nbm_county` (syncing only the relevant
state via `aws s3 sync` before querying from disk) avoids this problem
entirely and is the recommended approach for repeated or
latency-sensitive queries.

[^1]: This data describes what internet services are available to
    individual locations across the country, along with new maps of
    mobile coverage, as reported by Internet Service Providers (ISPs).
    It is part of the FCC’s ongoing [Broadband Data
    Collection](https://broadbandmap.fcc.gov/data-download/nationwide-data)).
