# This function is required to download the valid grids from the distant folder on Zenodo.
# This way, there is no need to run the Rcpp files "row_generator.cpp", "grid_generator.cpp",
# "bigger_grid_generator.cpp".

library(readr)
dl_csv <- function(){
  grids_4 <- as.matrix(read_csv("https://zenodo.org/records/15037448/files/valid_grid_4x4.csv?download=1", col_names = FALSE))
  grids_6 <- as.matrix(read_csv("https://zenodo.org/records/15037448/files/valid_grid_6x6.csv?download=1", col_names = FALSE))
  grids_8 <- as.matrix(read_csv("https://zenodo.org/records/15037448/files/valid_grid_8x8.csv?download=1", col_names = FALSE))

  all_grids <- list()

  for (n in c(4, 6, 8)) {
    grids_n <- get(paste0("grids_", n))
    num_grids <- nrow(grids_n) / n

    grids_n_list <- lapply(1:num_grids, function(i) {
      grids_n[((i - 1) * n + 1):(i * n), ]
    })

    all_grids[[paste0("grids_", n)]] <- grids_n_list
  }

  return(all_grids)
}

