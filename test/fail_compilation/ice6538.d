

/**************************************/
// 9361

/*
TEST_OUTPUT:
---
fail_compilation/ice6538.d(22): Error: expression super is not a valid template value argument
fail_compilation/ice6538.d(27):        instantiated from here: ice6538.D.foo!()()
---
*/

template Sym(alias A)
{
    enum Sym = true;
}

class C {}
class D : C
{
    void foo()() if (Sym!(super)) {}
}
void test9361b()
{
    auto d = new D();
    d.foo();
}

