/*
TEST_OUTPUT:
---
fail_compilation/fail25.d(14): Error: 'this' is only defined in non-static member functions, not asdfg
---
*/

class Qwert
{
    int yuiop;

    static int asdfg()
    {
        return Qwert.yuiop + 105;
    }
}
