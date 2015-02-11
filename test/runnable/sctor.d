// REQUIRED_ARGS:
// PERMUTE_ARGS: -w -d -de -dw

extern(C) int printf(const char*, ...);

/***************************************************/
// mutable field

struct S1A
{
    int v;
    this(int)
    {
        v = 1;
        v = 2;  // multiple initialization
    }
}

struct S1B
{
    int v;
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

struct S1C
{
    int v;
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

struct S2
{
    immutable int v;
    immutable int w;
    int x;
    this(int)
    {
        if (true) v = 1;
        else      v = 2;

        true ? (w = 1) : (w = 2);

        x = 1;  // initialization
    L:  x = 2;  // assignment after labels
    }
    this(long n)
    {
        if (n > 0)
            return;
        v = 1;  // skipped initialization

        // w skipped initialization

        x = 1;  // initialization
        foreach (i; 0..1) x = 2;  // assignment in loops
    }
}

/***************************************************/
// with immutable constructor

struct S3
{
    int v;
    int w;
    this(int) immutable
    {
        if (true) v = 1;
        else      v = 2;

        true ? (w = 1) : (w = 2);
    }
}

/***************************************************/
// in typeof

struct S4
{
    immutable int v;
    this(int)
    {
        static assert(is(typeof(v = 1)));
        v = 1;
    }
}

/***************************************************/
// 8117

struct S8117
{
    @disable this();
    this(int) {}
}

class C8117
{
    S8117 s = S8117(1);
}

void test8117()
{
    auto t = new C8117();
}

/***************************************************/
// 9665

struct X9665
{
    static uint count;
    ulong payload;
    this(int n) { payload = n; count += 1; }
    this(string s) immutable { payload = s.length; count += 10; }
    void opAssign(X9665 x) { payload = 100; count += 100; }
}

struct S9665
{
              X9665 mval;
    immutable X9665 ival;
    this(int n)
    {
        X9665.count = 0;
        mval = X9665(n);                // 1st, initializing
        ival = immutable X9665("hi");   // 1st, initializing
        mval = X9665(1);                // 2nd, assignment
        static assert(!__traits(compiles, ival = immutable X9665(1)));  // 2nd, assignment
        //printf("X9665.count = %d\n", X9665.count);
        assert(X9665.count == 112);
    }
    this(int[])
    {
        X9665.count = 0;
        mval = 1;       // 1st, initializing (implicit constructor call)
        ival = "hoo";   // ditto
        assert(X9665.count == 11);
    }
}

void test9665()
{
    S9665 s1 = S9665(1);
    assert(s1.mval.payload == 100);
    assert(s1.ival.payload == 2);

    S9665 s2 = S9665([]);
    assert(s2.mval.payload == 1);
    assert(s2.ival.payload == 3);
}

/***************************************************/
// 11246

struct Foo11246
{
    static int ctor = 0;
    static int dtor = 0;
    this(int i)
    {
        ++ctor;
    }

    ~this()
    {
        ++dtor;
    }
}

struct Bar11246
{
    Foo11246 foo;

    this(int)
    {
        foo = Foo11246(5);
        assert(Foo11246.ctor == 1);
        assert(Foo11246.dtor == 0);
    }
}

void test11246()
{
    {
        auto bar = Bar11246(1);
        assert(Foo11246.ctor == 1);
        assert(Foo11246.dtor == 0);
    }
    assert(Foo11246.ctor == 1);
    assert(Foo11246.dtor == 1);
}

/***************************************************/
// 13515

Object[string][100] aa13515;

static this()
{
    aa13515[5]["foo"] = null;
}

struct S13515
{
    Object[string][100] aa;

    this(int n)
    {
        aa[5]["foo"] = null;
    }
}

void test13515()
{
    assert(aa13515[5].length == 1);
    assert(aa13515[5]["foo"] is null);

    auto s = S13515(1);
    assert(s.aa[5].length == 1);
    assert(s.aa[5]["foo"] is null);
}

/***************************************************/

immutable int g;

class C1
{
    int* p;
    this(int) pure { static assert(!__traits(compiles, (p = &g))); }
}
class C2
{
    int* p;
    this(int) const pure { p = &g;  }
}
class C3
{
    int* p;
    this(int) immutable pure { p = &g; }
}
void testC()
{
                 C1 m1  = new              C1(1);
          shared C1 s1  = new       shared C1(1);
           const C1 c1  = new        const C1(1);
    shared const C1 sc1 = new shared const C1(1);
       immutable C1 i1  = new    immutable C1(1);

    static assert(!__traits(compiles, {        C2 m2 = new        C2(2); }));
    static assert(!__traits(compiles, { shared C2 s2 = new shared C2(2); }));
           const C2 c2  = new        const C2(2);
    shared const C2 sc2 = new shared const C2(2);
       immutable C2 i2  = new    immutable C2(2);

    static assert(!__traits(compiles, {        C3 m3 = new        C3(3); }));
    static assert(!__traits(compiles, { shared C3 s3 = new shared C3(3); }));
           const C3 c3  = new        const C3(3);
    shared const C3 sc3 = new shared const C3(3);
       immutable C3 i3  = new    immutable C3(3);
}

class T1
{
    int* p;
    this(T)(T) pure { static assert(!__traits(compiles, (p = &g))); }
}
class T2
{
    int* p;
    this(T)(T) const pure { p = &g;  }
}
class T3
{
    int* p;
    this(T)(T) immutable pure { p = &g; }
}
void testT()
{
                 T1 m1  = new              T1(1);
          shared T1 s1  = new       shared T1(1);
           const T1 c1  = new        const T1(1);
    shared const T1 sc1 = new shared const T1(1);
       immutable T1 i1  = new    immutable T1(1);

    static assert(!__traits(compiles, {        T2 m2 = new        T2(2); }));
    static assert(!__traits(compiles, { shared T2 s2 = new shared T2(2); }));
           const T2 c2  = new        const T2(2);
    shared const T2 sc2 = new shared const T2(2);
       immutable T2 i2  = new    immutable T2(2);

    static assert(!__traits(compiles, {        T3 m3 = new        T3(3); }));
    static assert(!__traits(compiles, { shared T3 s3 = new shared T3(3); }));
           const T3 c3  = new        const T3(3);
    shared const T3 sc3 = new shared const T3(3);
       immutable T3 i3  = new    immutable T3(3);
}

/***************************************************/

int main()
{
    test8117();
    test9665();
    test11246();
    test13515();

    printf("Success\n");
    return 0;
}
