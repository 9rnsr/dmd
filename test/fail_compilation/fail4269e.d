// REQUIRED_ARGS: -d
/*
TEST_OUTPUT:
---
fail_compilation/fail4269e.d(10): Error: undefined identifier Y
---
*/

static if (is(typeof(X5.init))) {}
typedef Y X5;
