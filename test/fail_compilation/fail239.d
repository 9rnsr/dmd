/*
TEST_OUTPUT:
---
fail_compilation/fail239.d(10): Error: argument F to typeof is not an expression
fail_compilation/fail239.d(10): Error: argument F to typeof is not an expression
---
*/

class F { int x; }
alias typeof(F).x b;
