// REQUIRED_ARGS: -o-
/*
TEST_OUTPUT:
---
fail_compilation/fail13494b.d(18): Error: compile-time delegate literal cannot access outer nested class 'D'
fail_compilation/fail13494b.d(25): Error: compile-time delegate literal cannot access outer variable 'a'
fail_compilation/fail13494b.d(28): Error: compile-time delegate literal cannot access outer local function 'foo'
fail_compilation/fail13494b.d(31): Error: compile-time delegate literal cannot access outer nested class 'N'
---
*/

class C
{
    class D {}

    void foo()
    {
        static void delegate() dg = { auto d = new D(); };
    }
}

void main()
{
    int a;
    static void delegate(dchar) dg1 = (dchar c) { int n = a; };

    void foo() {}
    static void delegate(dchar) dg2 = (dchar c) { foo(); };

    class N {}
    static void delegate() dg = { auto d = new N(); };
}
