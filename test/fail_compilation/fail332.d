/*
TEST_OUTPUT:
---
fail_compilation/fail332.d(14): Error: function fail332.foo (int, ...) is not callable using argument types ()
---
*/

import core.vararg;

void foo(int, ...) {}

void bar()
{
    foo();
}
