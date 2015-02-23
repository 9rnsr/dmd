// REQUIRED_ARGS:
// PERMUTE_ARGS:

/***************************************************/
// immutable field

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(19): Error: immutable field 'v' initialized multiple times
---
+/
struct S1A
{
    immutable int v;
    this(int)
    {
        v = 1;
        v = 2;  // multiple initialization
    }
}

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(37): Error: immutable field 'v' initialized multiple times
fail_compilation/fail9665.d(42): Error: immutable field 'v' initialized multiple times
fail_compilation/fail9665.d(47): Error: immutable field 'v' initialized multiple times
---
+/
struct S1B
{
    immutable int v;
    this(int)
    {
        if (true) v = 1; else v = 2;
        v = 3;  // multiple initialization
    }
    this(long)
    {
        if (true) v = 1;
        v = 3;  // multiple initialization
    }
    this(string)
    {
        if (true) {} else v = 2;
        v = 3;  // multiple initialization
    }
}

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(65): Error: immutable field 'v' initialized multiple times
fail_compilation/fail9665.d(70): Error: immutable field 'v' initialized multiple times
fail_compilation/fail9665.d(75): Error: immutable field 'v' initialized multiple times
---
+/
struct S1C
{
    immutable int v;
    this(int)
    {
        true ? (v = 1) : (v = 2);
        v = 3;  // multiple initialization
    }
    this(long)
    {
        auto x = true ? (v = 1) : 2;
        v = 3;  // multiple initialization
    }
    this(string)
    {
        auto x = true ? 1 : (v = 2);
        v = 3;  // multiple initialization
    }
}

/***************************************************/
// with control flow

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(98): Error: immutable field 'v' initialization is not allowed in loops or after labels
fail_compilation/fail9665.d(103): Error: immutable field 'v' initialization is not allowed in loops or after labels
fail_compilation/fail9665.d(108): Error: immutable field 'v' initialized multiple times
fail_compilation/fail9665.d(113): Error: immutable field 'v' initialized multiple times
fail_compilation/fail9665.d(118): Error: immutable field 'v' initialized multiple times
---
+/
struct S2
{
    immutable int v;
    this(int)
    {
    L:
        v = 1;  // after labels
    }
    this(long)
    {
        foreach (i; 0..1)
            v = 1;  // in loops
    }
    this(string)
    {
        v = 1;  // initialization
    L:  v = 2;  // assignment after labels
    }
    this(wstring)
    {
        v = 1;  // initialization
        foreach (i; 0..1) v = 2;  // assignment in loops
    }
    this(dstring)
    {
        v = 1; return;
        v = 2;  // multiple initialization
    }
}

/***************************************************/
// with immutable constructor

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(139): Error: immutable field 'v' initialized multiple times
fail_compilation/fail9665.d(143): Error: immutable field 'w' initialized multiple times
---
+/
struct S3
{
    int v;
    int w;
    this(int) immutable
    {
        v = 1;
        v = 2;  // multiple initialization

        if (true)
            w = 1;
        w = 2;  // multiple initialization
    }
}

/***************************************************/
// in __traits(compiles)

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(162): Error: immutable field 'v' initialized multiple times
---
+/
struct S4
{
    immutable int v;
    this(int)
    {
        static assert(__traits(compiles, v = 1));
        v = 1;  // multiple initialization
    }
}

/***************************************************/
// with disable this() struct

struct X
{
    @disable this();

    this(int) {}
}

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(197): Error: one path skips field x2
fail_compilation/fail9665.d(198): Error: one path skips field x3
fail_compilation/fail9665.d(200): Error: one path skips field x5
fail_compilation/fail9665.d(201): Error: one path skips field x6
fail_compilation/fail9665.d(195): Error: field x1 must be initialized in constructor
fail_compilation/fail9665.d(195): Error: field x4 must be initialized in constructor
---
+/
struct S5
{
    X x1;
    X x2;
    X x3;
    X[2] x4;
    X[2] x5;
    X[2] x6;
    this(int)
    {
        if (true) x2 = X(1);
        auto n = true ? (x3 = X(1), 1) : 2;

        if (true) x5 = X(1);
        auto m = true ? (x6 = X(1), 1) : 2;
    }
}

/***************************************************/
// with nested struct

/+
TEST_OUTPUT:
---
fail_compilation/fail9665.d(230): Error: one path skips field x2
fail_compilation/fail9665.d(231): Error: one path skips field x3
fail_compilation/fail9665.d(233): Error: one path skips field x5
fail_compilation/fail9665.d(234): Error: one path skips field x6
fail_compilation/fail9665.d(228): Error: field x1 must be initialized in constructor, because it is nested struct
fail_compilation/fail9665.d(228): Error: field x4 must be initialized in constructor, because it is nested struct
fail_compilation/fail9665.d(241): Error: template instance fail9665.S6!(X) error instantiating
---
+/
struct S6(X)
{
    X x1;
    X x2;
    X x3;
    X[2] x4;
    X[2] x5;
    X[2] x6;
    this(X x)
    {
        if (true) x2 = x;
        auto a = true ? (x3 = x, 1) : 2;

        if (true) x5 = x;
        auto b = true ? (x6 = x, 1) : 2;
    }
}
void test6()
{
    struct X { this(int) {} }
    static assert(X.tupleof.length == 1);
    S6!(X) s = X(1);
}

/***************************************************/
// 12749 - in constructor local functions

struct Aggr12749
{
    int opApply(int delegate(int) dg) { return dg(1); }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail9665.d(270): Error: immutable field 'inum' initialization is not allowed in foreach loop
fail_compilation/fail9665.d(271): Error: const field 'cnum' initialization is not allowed in foreach loop
fail_compilation/fail9665.d(276): Error: immutable field 'inum' initialization is not allowed in nested function 'set'
fail_compilation/fail9665.d(277): Error: const field 'cnum' initialization is not allowed in nested function 'set'
---
*/
struct S12749
{
    immutable int inum;
    const     int cnum;

    this(int i)
    {
        foreach (n; Aggr12749())
        {
            inum = i;
            cnum = i;
        }

        void set(int i)
        {
            inum = i;
            cnum = i;
        }
    }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail9665.d(299): Error: immutable variable 'inum12749' initialization is not allowed in foreach loop
fail_compilation/fail9665.d(300): Error: const variable 'cnum12749' initialization is not allowed in foreach loop
fail_compilation/fail9665.d(305): Error: immutable variable 'inum12749' initialization is not allowed in nested function 'set'
fail_compilation/fail9665.d(306): Error: const variable 'cnum12749' initialization is not allowed in nested function 'set'
---
*/
immutable int inum12749;
const     int cnum12749;
static this()
{
    int i = 10;

    foreach (n; Aggr12749())
    {
        inum12749 = i;
        cnum12749 = i;
    }

    void set(int i)
    {
        inum12749 = i;
        cnum12749 = i;
    }
}

/***************************************************/
// 12678 - diagnostic message improvement

/*
TEST_OUTPUT:
---
fail_compilation/fail9665.d(330): Error: const field 'cf1' initialized multiple times
fail_compilation/fail9665.d(333): Error: immutable field 'if1' initialized multiple times
fail_compilation/fail9665.d(336): Error: const field 'cf2' initialization is not allowed in loops or after labels
---
*/
struct S12678
{
    const int cf1;
    const int cf2;
    immutable int if1;

    this(int x)
    {
        cf1 = x;
        cf1 = x;    // error

        if1 = x;
        if1 = x;    // error

        foreach (i; 0 .. 5)
            cf2 = x;    // error
    }
}

/***************************************************/
// 10496 - in constructor local functions (for a lazy parameter)

/*
TEST_OUTPUT:
---
fail_compilation/fail9665.d(355): Error: field initialization 'this.x = 5' is not allowed in nested function '__dgliteral1'
---
*/
class C10496
{
    immutable int x;

    this()
    {
        this.f(this.x = 5);
    }

    void f(lazy int x){}
}
