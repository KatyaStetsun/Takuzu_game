#include <Rcpp.h>
#include <fstream>
#include <vector>
#include <sstream>
#include <algorithm>

using namespace Rcpp;
using namespace std;

// same function as in grid_generator.cpp
// faster than #include "grid_generator.h"
bool isValidBiggerGrid(const vector<vector<int>>& grid, int size) {
  if (grid.size() < size) {
    return true;
  }

  for (int col = 0; col < size; col++) {
    int zeros = 0, ones = 0;
    for (int row = 0; row < size; row++) {
      if (grid[row][col] == 0) zeros++;
      else ones++;

      // check succesive 1s and 0s
      if (row >= 2 && grid[row][col] == grid[row - 1][col] && grid[row][col] == grid[row - 2][col]) {
        return false;
      }
    }

    // check number of 1s and 0s
    if (zeros != ones) {
      return false;
    }

    // check for duplicated columns
    for (int col1 = 0; col1 < size; col1++) {
      for (int col2 = col1 + 1; col2 < size; col2++) {
        bool isDuplicate = true;
        for (int row = 0; row < size; row++) {
          if (grid[row][col1] != grid[row][col2]) {
            isDuplicate = false;
            break;
          }
        }
        //
        if (isDuplicate) {
          return false;
        }
      }
    }
  }

    // Check for duplicated rows
    for (int row1 = 0; row1 < size; row1++) {
      for (int row2 = row1 + 1; row2 < size; row2++) {
        bool isDuplicate = true;
        for (int col = 0; col < size; col++) {
          if (grid[row1][col] != grid[row2][col]) {
            isDuplicate = false;
            break;
          }
        }
        if (isDuplicate) {
          return false;
        }
      }
    }

  return true;
}


vector<vector<vector<int>>> readGridsFromFile(const string& filename) {
  ifstream infile(filename);
  string line;
  vector<vector<vector<int>>> grids;
  vector<vector<int>> currentGrid;

  while (getline(infile, line)) {
    if (line.empty()) {
      if (!currentGrid.empty()) {
        grids.push_back(currentGrid);
        currentGrid.clear();
      }
      continue;
    }

    stringstream ss(line);
    vector<int> row;
    string value;

    while (getline(ss, value, ',')) {
      row.push_back(stoi(value));
    }

    if (row.size() == 4) {
      currentGrid.push_back(row);
    }

    if (currentGrid.size() == 4) {
      grids.push_back(currentGrid);
      currentGrid.clear();
    }
  }

  if (!currentGrid.empty()) {
    grids.push_back(currentGrid);
  }

  infile.close();

  Rcout << "Total valid 4x4 grids read: " << grids.size() << "\n";
  for (const auto& grid : grids) {
    Rcout << "Read grid:\n";
    for (const auto& row : grid) {
      for (int val : row) {
        Rcout << val << " ";
      }
      Rcout << "\n";
    }
    Rcout << "--------\n";
  }

  return grids;
}


void generateBiggerGrids(vector<vector<vector<int>>>& validGrids, vector<vector<vector<int>>>& validBiggerGrids) {
  int n = validGrids.size();

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      for (int k = 0; k < n; k++) {
        for (int l = 0; l < n; l++) {
          vector<vector<int>> grid(8, vector<int>(8));

          // Top-left block
          for (int r = 0; r < 4; r++) {
            for (int c = 0; c < 4; c++) {
              grid[r][c] = validGrids[i][r][c];
            }
          }

          // Top-right block
          for (int r = 0; r < 4; r++) {
            for (int c = 4; c < 8; c++) {
              grid[r][c] = validGrids[j][r][c - 4];
            }
          }

          // Bottom-left block
          for (int r = 4; r < 8; r++) {
            for (int c = 0; c < 4; c++) {
              grid[r][c] = validGrids[k][r - 4][c];
            }
          }

          // Bottom-right block
          for (int r = 4; r < 8; r++) {
            for (int c = 4; c < 8; c++) {
              grid[r][c] = validGrids[l][r - 4][c - 4];
            }
          }

          if (isValidBiggerGrid(grid, 8)) {
            validBiggerGrids.push_back(grid);
          }
        }
      }
    }
  }
}


void saveBiggerGridsToFile(const vector<vector<vector<int>>>& grids, int size, const string& output_dir) {
  string filename = output_dir + "/valid_grid_" + to_string(size) + "x" + to_string(size) + ".csv";
  ofstream outfile(filename);

  if (!outfile) {
    Rcout << "Error opening file: " << filename << "\n";
    return;
  }

  for (const auto& grid : grids) {
    for (const auto& row : grid) {
      for (size_t i = 0; i < row.size(); i++) {
        outfile << row[i];
        if (i < row.size() - 1) outfile << ",";
      }
      outfile << "\n";
    }
    outfile << "\n";
  }

  outfile.close();
  Rcout << "Saved " << grids.size() << " valid 8x8 grids to " << filename << "\n";
}


void generateBiggerGrids(const string& input_file, const string& output_dir) {
  vector<vector<vector<int>>> validGrids = readGridsFromFile(input_file);

  if (validGrids.empty()) {
    Rcout << "No valid 4x4 grids found.\n";
    return;
  }

  Rcout << "Generated " << validGrids.size() << " valid 4x4 grids.\n";

  vector<vector<vector<int>>> validBiggerGrids;
  generateBiggerGrids(validGrids, validBiggerGrids);

  saveBiggerGridsToFile(validBiggerGrids, 8, output_dir);
}


/*** R
#generateBiggerGrids("src/valid_grid_4x4.csv", "src")
*/
