\name{generateValidRows}
\alias{generateValidRows}
\title{Generate Valid Rows for Takuzu Grids}
\description{
  This function generates all valid Takuzu rows of a given size. The rows are
  binary sequences that follow the rules of Takuzu, including balanced number
  of 1s and 0s, and no three consecutive identical digits.
}
\usage{
generateValidRows(size)
}
\arguments{
  \item{size}{An integer specifying the size of the rows to be generated. The
  function will generate all valid binary rows of this size.}
}
\value{
  A list of integer vectors, where each vector represents a valid Takuzu row.
}
\examples{
  # Generate all valid rows of size 4
  generateValidRows(4)
}
