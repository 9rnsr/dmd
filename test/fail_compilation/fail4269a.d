/*
TEST_OUTPUT:
---
fail_compilation/fail4269a.d(15): Error: undefined identifier B, did you mean interface A?
fail_compilation/fail4269a.d(15): Error: variable fail4269a.A.blah field not allowed in interface
fail_compilation/fail4269a.d(16): Error: undefined identifier B, did you mean interface A?
fail_compilation/fail4269a.d(16): Error: function fail4269a.A.foo function body only allowed in final functions in interface A
---
*/

enum bool test = is(typeof(A.x));

interface A
{
    B blah;
    void foo(B b) {}
}
