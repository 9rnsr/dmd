/*
TEST_OUTPUT:
---
fail_compilation/fail_DIPxx.d(18): Error: template fail_DIPxx.foo cannot deduce function from argument types !()(string), candidates are:
fail_compilation/fail_DIPxx.d(14):        fail_DIPxx.foo(T if isFoo)(T t)
---
*/

template isFoo(T) if (is(T == int))
{
    enum bool isFoo = true;
}

void foo(T if isFoo)(T t) {}

void main()
{
    foo("a");
}
