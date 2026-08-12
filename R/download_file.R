#' Download file function (replacement for download.file)
#'
#' @param remote_file_url URL to download file from
#' @param local_file_path Local path to save file to
#'
#' @return path to local file
#'
#' @keywords internal
#'
download_file <- function (remote_file_url, local_file_path) {
  status_file <- tempfile()
  on.exit(unlink(status_file), add = TRUE)

  res <- system(
    sprintf(
      paste0("curl '%s' --compressed -s ",
             "-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:131.0) Gecko/20100101 Firefox/131.0' ",
             "-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' ",
             "-H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' ",
             "-H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' ",
             "-H 'Referer: https://broadbandmap.fcc.gov/data-download' ",
             "-H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' ",
             "-H 'Sec-GPC: 1' -H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' ",
             "-o %s -w '%%{http_code}' > %s"),
      remote_file_url, local_file_path, status_file
    )
  )

  http_status <- if (file.exists(status_file)) {
    trimws(readLines(status_file, warn = FALSE, n = 1L))
  } else {
    ""
  }

  if (!is.null(res) && res == 0 && identical(http_status, "200")) {
    return(invisible(local_file_path))
  }

  # curl either failed outright or didn't get a 200 (e.g. blocked by a WAF
  # that still exits 0) -- fall back to wget, which has a different enough
  # TLS/HTTP fingerprint that it clears some blocks curl doesn't.
  wget_result <- tryCatch({
    if (!nzchar(Sys.which("wget"))) {
      stop("wget is not installed on this system", call. = FALSE)
    }

    res <- system(
      sprintf(
        paste0("wget '%s' --compression=auto ",
               "--header='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:131.0) Gecko/20100101 Firefox/131.0' ",
               "--header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' ",
               "--header='Accept-Language: en-US,en;q=0.5' ",
               "--header='Connection: keep-alive' --header='Upgrade-Insecure-Requests: 1' ",
               "--header='Referer: https://broadbandmap.fcc.gov/data-download' ",
               "--header='Sec-Fetch-Dest: document' --header='Sec-Fetch-Mode: navigate' --header='Sec-Fetch-Site: none' --header='Sec-Fetch-User: ?1' ",
               "--header='Sec-GPC: 1' --header='Pragma: no-cache' --header='Cache-Control: no-cache' ",
               "-O %s"),
        remote_file_url, local_file_path
      )
    )

    if (is.null(res) || res > 0) {
      stop(sprintf("wget exited with status %s", res), call. = FALSE)
    }

    local_file_path
  }, error = function(e) e)

  if (inherits(wget_result, "error")) {
    stop(sprintf(
      "Unable to download '%s': curl did not return a successful response (HTTP %s), and the wget fallback failed as well (%s).",
      remote_file_url,
      if (nzchar(http_status)) http_status else "no response",
      conditionMessage(wget_result)
    ), call. = FALSE)
  }

  invisible(wget_result)
}
