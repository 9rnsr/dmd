/*
TEST_OUTPUT:
---
fail_compilation/fail290.d(15): Error: 'this' is only defined in non-static member functions, not main
---
*/

struct Foo
{
    void foo(int x) {}
}

void main()
{
    void delegate (int) a = &Foo.foo;
}
