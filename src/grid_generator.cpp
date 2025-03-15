#include <Rcpp.h>
#include <fstream>
#include <vector>
#include <sstream>
#include <algorithm>

using namespace Rcpp;
using namespace std;

bool isValidGrid(const vector<vector<int>>& grid, int size) {
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

    // check for duplicates
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

  return true;
}


map<int, vector<vector<int>>> readValidRowsFromFile(const string& filename) {
  ifstream infile(filename);
  string line;
  map<int, vector<vector<int>>> validRowsBySize;

  while (getline(infile, line)) {
    stringstream ss(line);
    vector<int> row;
    int value;

    while (ss >> value) {
      row.push_back(value);
    }

    if (!row.empty()) {
      validRowsBySize[row.size()].push_back(row);
    }
  }

  infile.close();
  return validRowsBySize;
}


void saveValidGridsToFile(const vector<vector<vector<int>>>& grids, int size, const string& output_dir) {
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
  Rcout << "Saved " << grids.size() << " valid grids to " << filename << "\n";
}


void generateValidGrids(const std::string& filename, const std::string& output_dir, int size) {
  std::map<int, std::vector<std::vector<int>>> validRowsBySize = readValidRowsFromFile(filename);

  if (validRowsBySize.find(size) == validRowsBySize.end()) {
    Rcout << "No valid rows found for size " << size << ".\n";
    return;
  }

  const std::vector<std::vector<int>>& validRows = validRowsBySize[size];

  Rcout << "Size " << size << ": " << validRows.size() << " rows.\n";

  std::vector<std::vector<std::vector<int>>> validGrids;
  int nRows = validRows.size();

  std::vector<int> indices(size, 0);
  int validGridCount = 0;  // Initialize the counter for valid grids

  while (true) {
    std::vector<std::vector<int>> grid;
    for (int i = 0; i < size; i++) {
      grid.push_back(validRows[indices[i]]);
    }

    if (isValidGrid(grid, size)) {
      validGrids.push_back(grid);
      validGridCount++; // debbugging count
      Rcout << "Added valid grid #" << validGridCount << "\n";  // debugging Rcout
    }

    int idx = size - 1;
    while (idx >= 0 && indices[idx] == nRows - 1) {
      indices[idx] = 0;
      idx--;
    }
    if (idx < 0) break;
    indices[idx]++;
  }

  saveValidGridsToFile(validGrids, size, output_dir);
}

/*** R
# generateValidGrids("src/valid_rows.txt", "src", 4)
# generateValidGrids("src/valid_rows.txt", "src", 6)
*/
