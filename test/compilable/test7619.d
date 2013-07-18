// PERMUTE_ARGS: -d -dw -de
/*
TEST_OUTPUT:
---
---
*/

void main() {}

void foo(T)(T t){}

deprecated struct S {}

deprecated void test()
{
    S s;
    foo(s);
    // foo is instantiated with deprecated struct S.
}
