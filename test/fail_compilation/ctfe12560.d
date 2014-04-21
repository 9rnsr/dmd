struct A { ubyte b; }
struct B { short a; }

/+
bool test1()
{
    A[] a = []; void[] pa = a[];
    B[] b = []; void[] pb = b[];
    pa[] = pb[];    // OK
    return true;
}
static assert(test1());

/*
TETS_OUTPUT:
----
test.d(26): Error: reinterpret element-wise assignment from B to A via void[] is not allowed in compile time
test.d(34):        called from here: test2()
test.d(34):        while evaluating: static assert(test2())
---
*/
bool test2()
{
    A[] a = [ A(1), A(2) ]; void[] pa = a[];
    B[] b = [ B(3), B(4) ]; void[] pb = b[];
    pa[] = b[];
    return true;
}
static assert(test2());

/*
TETS_OUTPUT:
----
test.d(26): Error: reinterpret element-wise assignment from B to A via void[] is not allowed in compile time
test.d(34):        called from here: test2()
test.d(34):        while evaluating: static assert(test2())
---
*/
bool test3()
{
    A[] a = [ A(1), A(2) ]; void[] pa = a[];
    B[] b = [ B(3), B(4) ]; void[] pb = b[];
    pb[] = a[];
    return true;
}
static assert(test3());

/*
TETS_OUTPUT:
----
test.d(26): Error: reinterpret element-wise assignment from B to A via void[] is not allowed in compile time
test.d(34):        called from here: test2()
test.d(34):        while evaluating: static assert(test2())
---
*/
bool test4()
{
    A[] a = [ A(1), A(2) ]; void[] pa = a[];
    B[] b = [ B(3), B(4) ]; void[] pb = b[];
    pa[] = pb[];
    return true;
}
static assert(test4());

/*
TETS_OUTPUT:
----
test.d(26): Error: reinterpret element-wise assignment from B to A via void[] is not allowed in compile time
test.d(34):        called from here: test2()
test.d(34):        while evaluating: static assert(test2())
---
*/
bool test5()
{
    A[] a = [ A(1), A(2) ]; void[] pa = a[];
    B[] b = [ B(3), B(4) ]; void[] pb = b[];
    pb[] = pa[];
    return true;
}
static assert(test5());
+/


/*
TETS_OUTPUT:
----
test.d(26): Error: reinterpret element-wise assignment from B to A via void[] is not allowed in compile time
test.d(34):        called from here: test2()
test.d(34):        while evaluating: static assert(test2())
---
*/
bool test6()
{
    A[] a = [ A(1), A(2) ]; void[] pa = a[];
    B[] b = [ B(3) ];       void[] pb = b[];
    //assert(pa.length == pb.length);
    pa[0..$] = pb[];
    return true;
}
static assert(test6());

/*
TETS_OUTPUT:
----
test.d(26): Error: reinterpret element-wise assignment from B to A via void[] is not allowed in compile time
test.d(34):        called from here: test2()
test.d(34):        while evaluating: static assert(test2())
---
*/
bool test7()
{
    A[] a = [ A(1), A(2) ]; void[] pa = a[];
    B[] b = [ B(3) ];       void[] pb = b[];
    //assert(pa.length == pb.length);
    pb[] = pa[];
    return true;
}
static assert(test7());
