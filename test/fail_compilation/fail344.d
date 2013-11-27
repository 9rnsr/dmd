/*
TEST_OUTPUT:
---
fail_compilation/fail344.d(21): Error: undefined identifier Q
fail_compilation/fail344.d(21): Error: undefined identifier Q
fail_compilation/fail344.d(21): Error: undefined identifier V
fail_compilation/fail344.d(25): Error: template instance fail344.SIB!(crayon).SIB.Alike!(SIB!(crayon)) error instantiating
fail_compilation/fail344.d(31):        instantiated from here: opDispatch!"E"
fail_compilation/fail344.d(31): Error: template instance fail344.SIB!(crayon).SIB.opDispatch!"E" error instantiating
---
*/

// Issue 3737 - SEG-V at expression.c:6255 from bad opDispatch

int crayon;

struct SIB(alias junk)
{
    template Alike(V)
    {
        enum bool Alike = Q == V.garbage;
    }
    void opDispatch(string s)()
    {
        static assert(Alike!(SIB!(crayon)));
    }
}

void main()
{
    SIB!(SIB!(crayon).E)(3.0);
}
