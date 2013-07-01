// PERMUTE_ARGS:
// REQUIRED_ARGS: -D -Dd${RESULTS_DIR}/compilable -o-
// POST_SCRIPT: compilable/extra-files/ddocAny-postscript.sh inherit1

module ddocinherit1;

// 'inherit' does not work for private import
import imports.ddocinherit1a;           /// inherit

///
void test1() {}

// same as implicit private import
private import imports.ddocinherit1a;   /// inherit

///
void test2() {}

// works for public import
public import imports.ddocinherit1a;    /// inherit

///
void test3() {}

// No special handling for more than once import + inherit
public import imports.ddocinherit1a;    /// inherit
