/*
TEST_OUTPUT:
---
fail_compilation/fail1313.d(15): Error: escaping reference to local a
fail_compilation/fail1313.d(23): Error: escaping reference to local a
fail_compilation/fail1313.d(31): Error: escaping reference to local a
---
*/

int[] testa1()
//out{}
body
{
    int a[2];
    return a;
}

int[] testa2()
//out{}
body
{
    int a[2];
    return a[];
}

int[] testa3()
//out{}
body
{
    int a[2];
    return cast(int[])a;
}

/*
TEST_OUTPUT:
---
fail_compilation/fail1313.d(48): Error: escaping reference to local a
fail_compilation/fail1313.d(56): Error: escaping reference to local a
fail_compilation/fail1313.d(64): Error: escaping reference to local a
---
*/

int[] testb1()
out{}
body
{
    int a[2];
    return a;
}

int[] testb2()
out{}
body
{
    int a[2];
    return a[];
}

int[] testb3()
out{}
body
{
    int a[2];
    return cast(int[])a;
}
