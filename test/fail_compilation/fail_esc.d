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

/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(36): Error: escaping reference to scope local b of type int[]
fail_compilation/fail_esc.d(37): Error: escaping reference to scope local b of type int[]
fail_compilation/fail_esc.d(37): Error: escaping reference to scope local b of type int[]
---
*/
int[] f2(int[] a, scope int[] b)
{
    if (g == 1) return a[0..2]; // OK
    if (g == 2) return a;       // OK
    if (g == 3) return b[0..2]; // NG
    else        return b.length >= 2 ? b[0..2] : b; // NG
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(55): Error: escaping reference to local v of int
fail_compilation/fail_esc.d(56): Error: escaping reference to local a of int
fail_compilation/fail_esc.d(57): Error: escaping reference to local v of int
fail_compilation/fail_esc.d(57): Error: escaping reference to local a of int
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
fail_compilation/fail_esc.d(69): Error: escaping reference to variadic parameter a of type int[]
fail_compilation/fail_esc.d(70): Error: escaping reference to variadic parameter a of type int[]
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
fail_compilation/fail_esc.d(82): Error: escaping reference to scope local s of type object.Object
---
*/
Object f5(Object o, scope Object s)
{
    if (g == 1) return o;
    else        return s;
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_esc.d(94): Error: escaping reference to scope local dg2 of type void delegate()
---
*/
void delegate() f6(void delegate() dg1, scope void delegate() dg2)
{
    if (g == 1) return dg1;
    else        return dg2;
}
