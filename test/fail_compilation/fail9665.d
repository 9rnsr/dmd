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
