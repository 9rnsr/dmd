/*
TEST_OUTPUT:
---
fail_compilation/fail190.d(11): Error: can't have pointer to (int, int, int)
fail_compilation/fail190.d(18): Error: template instance fail190.f!(int, int, int) error instantiating
fail_compilation/fail190.d(18): Error: template fail190.f does not match function template declaration
fail_compilation/fail190.d(18): Error: template fail190.f(T...)(T x) cannot deduce template function from argument types !()(int, int, int)
---
*/

T* f(T...)(T x)
{
    return null;
}

void main()
{
    auto x = f(2,3,4);
    *x = *x;
}
