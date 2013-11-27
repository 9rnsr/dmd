/*
TEST_OUTPUT:
---
fail_compilation/fail17.d(12): Error: undefined identifier B
fail_compilation/fail17.d(12): Error: mixin fail17.A!int.A.B!(T, A!T) is not defined
fail_compilation/fail17.d(15): Error: template instance fail17.A!int error instantiating
---
*/

struct A(T)
{
    mixin B!(T, A!(T));
}

A!(int) x;
