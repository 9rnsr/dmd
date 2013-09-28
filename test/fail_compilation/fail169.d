/*
TEST_OUTPUT:
---
fail_compilation/fail169.d(8): Error: out cannot be const
---
*/

void foo(const out int x) { }
