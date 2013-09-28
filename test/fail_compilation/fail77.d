/*
TEST_OUTPUT:
---
fail_compilation/fail77.d(12): Error: e2ir: cannot cast & i of type int* to type ubyte[4]
---
*/

void test()
{
    int i;
    ubyte[4] ub;
    ub[] = cast(ubyte[4]) &i;
    //ub[] = (cast(ubyte*) &i)[0..4];
}

