#include <Rcpp.h>
#include <vector>
#include <fstream>

using namespace Rcpp;
using namespace std;

bool isValidRow(const vector<int>& row, int size) {
  int zeros = 0, ones = 0;

  for (int i = 0; i < size; i++) {
    if (row[i] == 0) zeros++;
    else ones++;

    // check successive 1s and 0s
    if (i >= 2 && row[i] == row[i - 1] && row[i] == row[i - 2]) {
      return false;
    }
  }

  // check number of 1s and 0s
  if (zeros != ones) return false;
  return true;
}


vector<int> intToBinaryRow(int num, int size) {
  vector<int> row(size);
  for (int i = 0; i < size; i++) {
    row[i] = (num >> (size - 1 - i)) & 1;
  }
  return row;
}


List generateValidRows(int size) {

  vector<int> row(size);
  int total = 1 << size; // 2^size, better than pow(2, size)
  vector<vector<int>> validRows;
  validRows.reserve(total);

  for (int num = 0; num < total; num++) {
    row = intToBinaryRow(num, size);

    if (isValidRow(row, size)) {
      validRows.push_back(row);
    }
  }

  int n = validRows.size();
  List result(n);
  for (int i = 0; i < n; i++) {
    result[i] = IntegerVector(validRows[i].begin(), validRows[i].end());
  }
  return result;
}

void saveValidRows(const String& filename) {

  ofstream outfile(filename);

  for(int i = 4; i < 9; i++) {
    if(i % 2 == 0) {

      List validRowsList = generateValidRows(i);

      for (int j = 0; j < validRowsList.size(); j++) {
        IntegerVector row = validRowsList[j];

        for (int k = 0; k < row.size(); k++) {
          outfile << row[k] << " ";
        }
        outfile << endl;
      }
    }
  }

  outfile.close();
}

/*** R
saveValidRows("valid_rows.txt")
*/
