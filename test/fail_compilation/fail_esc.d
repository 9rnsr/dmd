/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(13): Error: escaping reference to local sarray() of type int[3]
fail_compilation/fail_esc.d(18): Error: escaping reference to local variable a of type int[3]
---
*/

int[3] sarray() { return [1,2,3]; }

int[] f1()
{
    return sarray();
}
int[] f2()
{
    int[3] a;
    return a;
}
int[] f3(int[] a)
{
    return a[0..2]; // OK
}
