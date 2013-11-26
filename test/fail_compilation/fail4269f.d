/*
TEST_OUTPUT:
---
fail_compilation/fail4269f.d(9): Error: alias fail4269f.X16 cannot resolve
---
*/

static if (is(typeof(X16))) {}
alias X16 X16;
