/*
TEST_OUTPUT:
---
fail_compilation/fail233.d(10): Error: void does not have a default initializer
---
*/

void bug1176()
{
    void[1] v;
}
