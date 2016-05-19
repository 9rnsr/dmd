/*
TEST_OUTPUT:
---
fail_compilation/diag16021.d(9): Error: recursive template expansion A!(B)
fail_compilation/diag16021.d(16):        while looking for match for A!(B)
---
*/

class A(T) if (is(T : A!T))
// gives this error:
// Error: template instance x.A!(B) does not match template declaration A(T) if (is(T : A!T))
//        while looking for match for A!(B)
{
}

class B : A!B
{
}
