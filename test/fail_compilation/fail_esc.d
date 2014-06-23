int[3] garr;
int[3] sarr() { return [1,2,3]; }

int g;

/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(19): Error: escaping reference to local variable v of type int[3]
fail_compilation/fail_esc.d(20): Error: escaping reference to local variable a of type int[3]
fail_compilation/fail_esc.d(21): Error: escaping reference to local sarr() of type int[3]
---
*/
int[] f1(ref int[3] r, int[3] v)
{
    int[3] a;
    if (g == 1) return garr;    // OK
    if (g == 2) return r;       // OK
    if (g == 3) return v;       // NG
    if (g == 4) return a;       // NG
    else        return sarr();  // NG
}

int[] f2(ref int[] a, int[] b)
{
    if (g == 1) return a[0..2];                 // OK
    if (g == 2) return a;                       // OK
    if (g == 3) return g == 3 ? a[0..2] : a;    // OK
    if (g == 4) return b[0..2];                 // OK
    if (g == 5) return b;                       // OK
    else        return g == 6 ? b[0..2] : b;    // OK
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(49): Error: escaping reference to local v of int
fail_compilation/fail_esc.d(50): Error: escaping reference to local a of int
fail_compilation/fail_esc.d(51): Error: escaping reference to local v of int
fail_compilation/fail_esc.d(51): Error: escaping reference to local a of int
---
*/
int* f3(ref int r, int v)
{
    int a;
    if (g == 1) return &g;                  // OK
    if (g == 2) return &r;                  // OK
    if (g == 3) return v == 0 ? &g : &r;    // OK
    if (g == 4) return &v;                  // NG
    if (g == 5) return &a;                  // NG
    else        return v == 0 ? &v : &a;    // NG, NG
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(63): Error: escaping reference to variadic parameter a of type int[]
fail_compilation/fail_esc.d(64): Error: escaping reference to variadic parameter a of type int[]
---
*/
int[] f4(int[] a ...)
{
    if (g == 1) return a;
    else        return a[0..2];
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(78): Error: escaping reference to local b of int
fail_compilation/fail_esc.d(79): Error: escaping reference to local c of int
---
*/
int*[] f5(ref int a, int b)
{
    int c;
    return [&a,
            &b,
            &c];
}
