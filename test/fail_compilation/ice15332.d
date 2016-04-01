/*
TEST_OUTPUT:
---
fail_compilation/ice15332.d(16): Error: need 'this' for 'fun' of type 'int()'
fail_compilation/ice15332.d(17): Error: 'this' is only defined in non-static member functions, not __funcliteral2
---
*/

class C
{
    int fun() { return 5; }
    int var;

    void test()
    {
        int a1 = function() { return fun; }();
        int a2 = function() { return var; }();
    }
}
