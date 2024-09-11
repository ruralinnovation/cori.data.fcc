
state_abbr_lookup <- function(state_abbr) {

  stopifnot("state_abbr need to be a scalar" = length(state_abbr) == 1)

  if (is.numeric(state_abbr))  state_abbr <- as.character(state_abbr)

  st_upper <- toupper(state_abbr)

  st <- data.frame(state_name = c("Alabama", "Alaska", "Arizona",
                                  "Arkansas", "California", "Colorado",
                                  "Connecticut", "Delaware",
                                  "District of Columbia",
                                  "Florida", "Georgia", "Hawaii", "Idaho",
                                  "Illinois", "Indiana", "Iowa", "Kansas",
                                  "Kentucky", "Louisiana",
                                  "Maine", "Maryland",
                                  "Massachusetts", "Michigan", "Minnesota",
                                  "Mississippi", "Missouri", "Montana",
                                  "Nebraska", "Nevada", "New Hampshire",
                                  "New Jersey", "New Mexico", "New York",
                                  "North Carolina", "North Dakota",
                                  "Ohio", "Oklahoma", "Oregon",
                                  "Pennsylvania", "Rhode Island",
                                  "South Carolina", "South Dakota",
                                  "Tennessee", "Texas", "Utah",
                                  "Vermont", "Virginia", "Washington",
                                  "West Virginia", "Wisconsin", "Wyoming",
                                  "American Samoa", "Guam",
                                  "Northern Mariana Islands",
                                  "Puerto Rico", "Virgin Islands"),
                   state_abbr = c("AL", "AK",
                                  "AZ", "AR", "CA", "CO", "CT", "DE", "DC",
                                  "FL", "GA", "HI", "ID", "IL", "IN", "IA",
                                  "KS", "KY", "LA", "ME", "MD", "MA", "MI",
                                  "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                                  "NJ", "NM", "NY", "NC", "ND", "OH", "OK",
                                  "OR", "PA", "RI", "SC", "SD", "TN", "TX",
                                  "UT", "VT", "VA", "WA", "WV", "WI", "WY",
                                  "AS", "GU", "MP", "PR", "VI"),
                   state_fips = c("01", "02", "04", "05", "06", "08", "09",
                                  "10", "11", "12", "13", "15", "16", "17",
                                  "18", "19", "20", "21", "22", "23", "24",
                                  "25", "26", "27", "28", "29", "30", "31",
                                  "32", "33", "34", "35", "36", "37", "38",
                                  "39", "40", "41", "42", "44", "45", "46",
                                  "47", "48", "49", "50", "51", "53", "54",
                                  "55", "56", "60", "66", "69", "72", "78"))

  stopifnot("Could not find state_abbr" =  st_upper %in% c(st$state_abbr,
                                                           st$state_fips))

  if (st_upper %in% st$state_fips) {
    return(st$state_abbr[st$state_fips == st_upper])
  }

  return(st_upper)

}