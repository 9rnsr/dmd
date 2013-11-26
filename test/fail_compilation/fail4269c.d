/*
TEST_OUTPUT:
---
fail_compilation/fail4269c.d(13): Error: undefined identifier B
fail_compilation/fail4269c.d(14): Error: undefined identifier B
---
*/

enum bool test = is(typeof(A.x));

class A
{
    B blah;
    void foo(B b) {}
}
