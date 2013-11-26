/*
TEST_OUTPUT:
---
fail_compilation/fail233.d(10): Error: cannot implicitly convert expression (cast(ubyte)0u) of type ubyte to void[]
---
*/

void bug1176()
{
    void[1] v;
}
