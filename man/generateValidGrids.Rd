\name{generateValidGrids}
\alias{generateValidGrids}
\title{Generate Valid Takuzu Grids}
\description{
  This function generates all valid Takuzu grids of a given size.
}
\usage{
generateValidGrids(size)
}
\arguments{
  \item{size}{An integer specifying the size of the grids to be generated. The
  function will generate all valid binary grids of this size.}
}
\value{
  A list of integer matrices, where each matrix represents a valid Takuzu grid.
}
\examples{
  # Generate all valid grids of size 2
  generateValidGrids(2)
}
