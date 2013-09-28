/*
TEST_OUTPUT:
---
fail_compilation/fail186.d(11): Error: can't have array of (int)
fail_compilation/fail186.d(18): Error: template instance fail186.C!int error instantiating
---
*/

class C(T...)
{
    void a(T[] o)
    {
        foreach (p; o)
            int a = 1;
    }
}

alias C!(int) foo;
