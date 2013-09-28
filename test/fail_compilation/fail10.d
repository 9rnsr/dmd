/*
TEST_OUTPUT:
---
fail_compilation/fail10.d(19): Error: mixin Foo!y cannot resolve forward reference
fail_compilation/fail10.d(19): Error: mixin Foo!y cannot resolve forward reference
---
*/

template Foo(alias b)
{
    int a()
    {
        return b;
    }
}

void test()
{
    mixin Foo!(y) y;
}
