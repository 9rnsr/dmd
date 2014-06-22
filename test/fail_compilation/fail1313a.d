/*
TEST_OUTPUT:
---
fail_compilation/fail1313a.d(15): Error: escaping reference to local a
fail_compilation/fail1313a.d(23): Error: escaping reference to local a
fail_compilation/fail1313a.d(31): Error: escaping reference to local a
---
*/

int[] test1()
//out{}
body
{
    int a[2];
    return a;
}

int[] test2()
//out{}
body
{
    int a[2];
    return a[];
}

int[] test2()
//out{}
body
{
    int a[2];
    return cast(int[])a;
}
