// PERMUTE_ARGS:
// REQUIRED_ARGS: -D -Dd${RESULTS_DIR}/compilable -o-
// POST_SCRIPT: compilable/extra-files/ddocAny-postscript.sh DIPxx

module ddocDIPxx;

enum bool InputRange(R) = true;
enum bool IntValue(int n) = true;

template FooDIPxxa(R if InputRange) {}      ///
template FooDIPxxb(int v if IntValue) {}    ///
template FooDIPxxc(alias v if IntValue) {}  ///
template FooDIPxxd(A... if InputRange) {}   ///
template FooDIPxxe(InputRange R) {}         ///
template FooDIPxxf(InputRange A...) {}      ///
