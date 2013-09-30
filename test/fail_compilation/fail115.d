/*
TEST_OUTPUT:
---
fail_compilation/fail115.d(17): Error: mixin Foo!y cannot resolve forward reference
---
*/

// Issue 402 - compiler crash with mixin and forward reference

template Foo(alias b)
{
    int a() { return b; }
}

void main()
{
    mixin Foo!(y) y;
}
