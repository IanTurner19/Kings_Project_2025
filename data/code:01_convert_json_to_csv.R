# code/01_convert_json_to_csv.R
library(jsonlite)
library(dplyr)
library(stringr)
library(purrr)
library(readr)

in_dir  <- "data/raw"
out_dir <- "data"

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

json_files <- list.files(in_dir, pattern = "\\.json$", full.names = TRUE)

read_one <- function(f) {
  # robust read; handles jsonlines or array
  txt <- readLines(f, warn = FALSE, encoding = "UTF-8")
  txt <- paste(txt, collapse = "\n")
  objs <- unlist(regmatches(txt, gregexpr("\\{[\\s\\S]*?\\}", txt, perl = TRUE)))
  if (length(objs) == 0) stop(paste("No JSON objects in", f))
  fromJSON(paste0("[", paste(objs, collapse = ","), "]"), flatten = TRUE)
}

df <- map_dfr(json_files, ~ suppressWarnings(read_one(.x)) %>% mutate(source_file = basename(.x)))

write_csv(df, file.path(out_dir, "intl_per_game_clean.csv"))
cat("Wrote:", file.path(out_dir, "intl_per_game_clean.csv"), "\n")
