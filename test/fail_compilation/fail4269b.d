/*
TEST_OUTPUT:
---
fail_compilation/fail4269b.d(13): Error: undefined identifier B, did you mean struct A?
fail_compilation/fail4269b.d(14): Error: undefined identifier B, did you mean struct A?
---
*/

enum bool test = is(typeof(A.x));

struct A
{
    B blah;
    void foo(B b) {}
}
