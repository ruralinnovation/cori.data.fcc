echo "$(pwd)"

## Set memory limits
#ulimit -d 50331648 # server crash on 50331648 # 25165824 # 12582912  # Data segment size limit in kilobytes
#ulimit -v 50331648 # server crash on 50331648  # Virtual memory limit in kilobytes

## TODO: These are the duckdb queries that keeps killing the server:
#  WITH FILTERED as (
#  select
#    frn,
#    provider_id,
#    location_id,
#    brand_name,
#    technology,
#    max_advertised_download_speed,
#    max_advertised_upload_speed,
#    low_latency,
#      state_usps as geoid_st,
#      geoid_bl,
#    geoid_co
#  from
#    read_parquet('inst/ext_data/nbm/nbm_raw/*/*/*/*.parquet')
#  where
#    (max_advertised_download_speed = 0 AND
#    max_advertised_upload_speed = 0) = false
#      and low_latency = true and
#    -- here is the release
#      release = '2024-12-01'
#  )
#
#  insert into staging (frn, provider_id, location_id, brand_name, technology,
#                       max_advertised_download_speed,
#                       max_advertised_upload_speed,
#                       low_latency, geoid_st,  geoid_bl, geoid_co)
#  select
#    frn,
#    provider_id,
#    location_id,
#    brand_name,
#    technology,
#    max_advertised_download_speed,
#    max_advertised_upload_speed,
#    low_latency,
#    geoid_st,
#      geoid_bl,
#      geoid_co
#  from
#    filtered
#  where
#    technology = 0
#    or technology = 10
#    or technology = 40
#    or technology = 50
#    or technology = 71
#    or technology = 72;
#
#  ALTER TABLE nbm_block
#  add column cnt_total_locations integer;
#  update
#    nbm_block as t1
#  set
#    cnt_total_locations = t2.cnt_total_locations
#  from
#    (select
#    geoid_bl,
#    count(distinct location_id) as cnt_total_locations
#  from
#    read_parquet('inst/ext_data/nbm/nbm_raw/*/*/*/*.parquet')
#  where release = '2024-12-01'
#  group by
#    geoid_bl
#  ) as t2
#  where
#     t1.geoid_bl = t2.geoid_bl;
#
#Error in `duckdb_result()`:
#! rapi_execute: Failed to run query
#Error: Out of Memory Error: Allocation failure
#Backtrace:
#     ▆
#  1. ├─DBI::dbExecute(con, nbm_cori2)
#  2. ├─DBI::dbExecute(con, nbm_cori2)
#  3. │ ├─DBI::dbSendStatement(conn, statement, ...)
#  4. │ └─DBI::dbSendStatement(conn, statement, ...)
#  5. │   ├─DBI::dbSendQuery(conn, statement, ...)
#  6. │   └─duckdb::dbSendQuery(conn, statement, ...)
#  7. │     └─duckdb (local) .local(conn, statement, ...)
#  8. │       └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
#  9. │         └─duckdb:::duckdb_execute(res)
# 10. │           └─duckdb:::rethrow_rapi_execute(...)
# 11. │             ├─rlang::try_fetch(...)
# 12. │             │ ├─base::tryCatch(...)
# 13. │             │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
# 14. │             │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
# 15. │             │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
# 16. │             │ └─base::withCallingHandlers(...)
# 17. │             └─duckdb:::rapi_execute(stmt, convert_opts)
# 18. └─base::.handleSimpleError(...)
# 19.   └─rlang (local) h(simpleError(msg, call))
# 20.     └─handlers[[1L]](cnd)
# 21.       └─duckdb:::rethrow_error_from_rapi(e, call)
# 22.         └─rlang::abort(msg, call = call)
#Execution halted


nohup Rscript data-raw/nbm_block.R > process_nbm.log 2>&1 &

PID=$!

nohup cpulimit -p $PID -l 50 &

echo "The PID of this process is: $PID" >> process_nbm.log
echo "The PID of this process is: $PID"
echo "Watch with: tail -f $(pwd)/process_nbm.log"
