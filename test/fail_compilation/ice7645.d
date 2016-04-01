/*
TEST_OUTPUT:
---
fail_compilation/ice7645.d(28): Error: 'this' is only defined in non-static member functions, not main
fail_compilation/ice7645.d(31): Error: 'this' is only defined in non-static member functions, not main
---
*/

class C
{
    class C2()
    {
        char t;
    }
}

struct S
{
    struct S2(T)
    {
        void fn() {}
    }
}

void main()
{
    C c;
    auto v = c.C2!().t;

    S s;
    s.S2!int.fn();
}
