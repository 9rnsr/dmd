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
// unique postblit

void test1()
{
    static struct X
    {
        int[] arr;
        this(this) {}
    }

    static string res;
    void checkCalledPostblit(string expect, void delegate() dg, uint ln = __LINE__)
    {
        res = null;
        dg();
        import core.exception;
        //printf("m,c,i,u = %d,%d,%d,%d\n", m, c, i, u);
        if (res != expect)
            throw new AssertError(__FILE__, ln);
    }

    static struct S1
    {
        X x;
        this(this)       { res ~= 'm'; }
        this(this) const { res ~= 'c'; x = X([1,2,3]); }
        this(this) inout { res ~= 'u'; x = X([1,2,3]); }
    }
    {
                  S1 sm;
            const S1 sc;
        immutable S1 si;

        // assignment
        checkCalledPostblit("m", {           S1 s = sm; });
        checkCalledPostblit("c", {     const S1 s = sm; });
        checkCalledPostblit("u", { immutable S1 s = sm; });
        checkCalledPostblit("u", {           S1 s = sc; });
        checkCalledPostblit("c", {     const S1 s = sc; });
        checkCalledPostblit("u", { immutable S1 s = sc; });
        checkCalledPostblit("u", {           S1 s = si; });
        checkCalledPostblit("c", {     const S1 s = si; });
        checkCalledPostblit("c", { immutable S1 s = si; });
    }

    static struct S2
    {
        X x;
        this(this) immutable { res ~= 'i'; x = X([1,2,3]); }
        this(this) inout     { res ~= 'u'; x = X([1,2,3]); }
    }
    {
                  S2 sm;
            const S2 sc;
        immutable S2 si;

        // assignment
        checkCalledPostblit("u", {           S2 s = sm; });
        checkCalledPostblit("u", {     const S2 s = sm; });
        checkCalledPostblit("u", { immutable S2 s = sm; });
        checkCalledPostblit("u", {           S2 s = sc; });
        checkCalledPostblit("u", {     const S2 s = sc; });
        checkCalledPostblit("u", { immutable S2 s = sc; });
        checkCalledPostblit("u", {           S2 s = si; });
        checkCalledPostblit("i", {     const S2 s = si; });
        checkCalledPostblit("i", { immutable S2 s = si; });
    }

    static struct S3
    {
        X x;
        this(this) const     { res ~= 'c'; x = X([1,2,3]); }
        this(this) immutable { res ~= 'i'; x = X([1,2,3]); }
    }
    {
                  S3 sm;
            const S3 sc;
        immutable S3 si;

        // assignment
        checkCalledPostblit("c", {           S3 s = sm; });
        checkCalledPostblit("c", {     const S3 s = sm; });
        static assert(!is(typeof({ immutable S3 s = sm; })));
        static assert(!is(typeof({           S3 s = sc; })));
        checkCalledPostblit("c", {     const S3 s = sc; });
        static assert(!is(typeof({ immutable S3 s = sc; })));
        static assert(!is(typeof({           S3 s = si; })));
        checkCalledPostblit("c", {     const S3 s = si; });
        checkCalledPostblit("i", { immutable S3 s = si; });
    }

    {
        static struct SX { this(this) {} }
        static struct SSX { SX s; }

        SSX sm;
        SSX sm2 = sm;
        const SSX sc = sm;
        static assert(!__traits(compiles, { immutable si = sm; }));
    }
    {
        static struct YA
        {
            this(this) {}
        }
        static struct YB
        {
            this(this) immutable {}
        }
        static struct SY
        {
            YA ma;
            immutable YB ib;
        }

        SY sm;
        immutable SY si;
        static assert(!__traits(compiles, {           SY s = sm; }));
        static assert(!__traits(compiles, {     const SY s = sm; }));
        static assert(!__traits(compiles, { immutable SY s = sm; }));
        static assert(!__traits(compiles, {           SY s = si; }));
        static assert(!__traits(compiles, {     const SY s = si; }));
        static assert(!__traits(compiles, { immutable SY s = si; }));
    }
}

/***************************************************/

int main()
{
    test8117();
    test9665();
    test11246();
    test1();

    printf("Success\n");
    return 0;
}
