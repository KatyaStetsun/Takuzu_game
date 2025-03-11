#include <Rcpp.h>
#include "row_generator.h"

using namespace Rcpp;
using namespace std;

bool isValidGrid(const vector<vector<int>>& grid, int size) {
  for (int col = 0; col < size; col++) {
    int zeros = 0, ones = 0;
    for (int row = 0; row < size; row++) {
      if (grid[row][col] == 0) zeros++;
      else ones++;

      if (row >= 2 && grid[row][col] == grid[row - 1][col] && grid[row][col] == grid[row - 2][col]) {
        return false;
      }
    }

    if (zeros != ones) {
      return false;
    }
  }
  return true;
}


// [[Rcpp::export]]
List generateValidGrids(int size) {

  List validRowsList = generateValidRows(size);
  int nRows = validRowsList.size();

  vector<vector<int>> validRows;
  for (int i = 0; i < nRows; i++) {
    IntegerVector row = validRowsList[i];
    validRows.push_back(vector<int>(row.begin(), row.end()));
  }

  vector<vector<vector<int>>> validGrids;

  for (int i = 0; i < nRows; i++) {
    for (int j = 0; j < nRows; j++) {
      vector<vector<int>> grid(size, vector<int>(size));

      grid[0] = validRows[i];
      grid[1] = validRows[j];

      if (isValidGrid(grid, size)) {
        validGrids.push_back(grid);
      }
    }
  }

  int n = validGrids.size();
  List result(n);

  for (int i = 0; i < n; i++) {
    IntegerMatrix matrix(size, size);
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        matrix(row, col) = validGrids[i][row][col];
      }
    }
    result[i] = matrix;
  }

  return result;
}

