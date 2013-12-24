/*
TEST_OUTPUT:
---
fail_compilation/fail10346.d(11): Error: undefined identifier T
fail_compilation/fail10346.d(15): Error: template fail10346.bar does not match function template declaration
fail_compilation/fail10346.d(15): Error: template fail10346.bar(T x, T)(Foo!T) cannot deduce template function from argument types !(10)(Foo!int)
---
*/

struct Foo(T) {}
void bar(T x, T)(Foo!T) {}
void main()
{
    Foo!int spam;
    bar!10(spam);
}
