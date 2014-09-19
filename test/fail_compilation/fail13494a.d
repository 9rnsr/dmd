// REQUIRED_ARGS: -o-
/*
TEST_OUTPUT:
---
fail_compilation/fail13494a.d(14): Error: compile-time delegate literal cannot access outer variable 'a'
fail_compilation/fail13494a.d(17): Error: compile-time delegate literal cannot access outer function 'foo'
fail_compilation/fail13494a.d(20): Error: compile-time delegate literal cannot access outer nested class 'D'
---
*/

class C
{
    int a;
    void delegate(dchar) dg1 = (dchar c) { int n = a; };

    void foo() {}
    void delegate(dchar) dg2 = (dchar c) { foo(); };

    class D {}
    static void delegate() dg = { auto d = new D(); };
}
