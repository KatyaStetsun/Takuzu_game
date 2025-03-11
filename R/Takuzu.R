#' Generating Valid Rows for Takuzu Grids
#'
#' @param size row size (also equal to column size)
#' @return List of complete valid rows
#' @export
generateValidRows <- function(size) {
  .Call(`_TakuzuKL_generateValidRows`, size)
}

#' Generating Valid Takuzu Grids
#'
#' @param size grid size (equal to row size above)
#' @return List of complete valid grids
#' @export
generateValidGrids <- function(size) {
  .Call(`_TakuzuKL_generateValidGrids`, size)
}
