/*
TEST_OUTPUT:
---
fail_compilation/fail10346.d(10): Error: undefined identifier T
fail_compilation/fail10346.d(14):        instantiated from here: fail10346.bar!(10)(Foo!int)
---
*/

struct Foo(T) {}
void bar(T x, T)(Foo!T) {}
void main()
{
    Foo!int spam;
    bar!10(spam);
}
