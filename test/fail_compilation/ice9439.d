/*
TEST_OUTPUT:
---
fail_compilation/ice9439.d(14): Error: value of 'this' is not known at compile time
fail_compilation/ice9439.d(14):        while evaluating: static assert(this.foo())
fail_compilation/ice9439.d(23): Error: template instance ice9439.D9439.boo!(foo) error instantiating
---
*/

class B9439
{
    void boo(alias F)()
    {
        static assert(F());
    }
}

class D9439 : B9439
{
    int foo() { return 1; }
    void bug()
    {
        boo!(foo)();
    }
}
