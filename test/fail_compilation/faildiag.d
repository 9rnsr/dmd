/*
TEST_OUTPUT:
---
fail_compilation/faildiag.d(31): Error: function faildiag.foo1 (int) is not callable using argument types (double)
fail_compilation/faildiag.d(32): Error: function faildiag.foo2 (int) is not callable using argument types (double)
fail_compilation/faildiag.d(33): Error: function faildiag.foo3()(int).foo3 (int) is not callable using argument types (double)
fail_compilation/faildiag.d(34): Error: template faildiag.foo4 cannot deduce template function from argument types !()(double), Candidates are:
fail_compilation/faildiag.d(24):        faildiag.foo4()()
fail_compilation/faildiag.d(25):        faildiag.foo4(T)(T) if (is(T == int))
fail_compilation/faildiag.d(35): Error: template faildiag.foo5 cannot deduce template function from argument types !()(double), Candidates are:
fail_compilation/faildiag.d(27):        faildiag.foo5()()
---
*/

void foo1() {}
void foo1(int) {}

void foo2()() {}
void foo2(int) {}

void foo3() {}
void foo3()(int) {}

void foo4()() {}
void foo4(T)(T) if (is(T == int)) {}

void foo5()() {}

void main()
{
    foo1(1.0);
    foo2(1.0);
    foo3(1.0);
    foo4(1.0);
    foo5(1.0);
}
