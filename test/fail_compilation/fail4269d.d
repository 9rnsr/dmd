/*
TEST_OUTPUT:
---
fail_compilation/fail4269d.d(9): Error: undefined identifier Y, did you mean alias X6?
---
*/

static if (is(typeof(X6.init))) {}
alias Y X6;
