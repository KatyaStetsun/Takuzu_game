#ifndef ROW_GENERATOR_H
#define ROW_GENERATOR_H

#include <Rcpp.h>
#include <vector>

using namespace Rcpp;
using namespace std;

// Function declarations
bool isValidRow(const vector<int>& row, int size);
vector<int> intToBinaryRow(int num, int size);
List generateValidRows(int size);

#endif
