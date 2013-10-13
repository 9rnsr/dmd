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

struct S1X
{
    int[] arr;
}

struct S1Y
{
    int[] arr;
    this(int) inout { arr = new int[](3); }
}

struct S1Z
{
    int[] a1;

    const int[][] aoa;

    int n;      int[] na;
    double r;   double[] ra;
    cdouble c;  cdouble[] ca;

    void function() fp;
    void delegate() dg;

    void function()[] fps;
    void delegate()[] dgs;

    S1X sx;
    S1Y sy;

    int[][string] aa1, aa2;

    int[] cat1, cat2, cat3;
    int[][] cat4;

    int[] dotvar1, dotvar2;

    int[] slice1, slice2;

    this(int[] a) inout
    {
        static assert(!__traits(compiles, a1 = a));
        aoa = [[1, a[0]], [], a.dup, new int[](5)];

        n = 1024;  na = [1024];
        r = 3.14;  ra = [3.14];
        c = 2+3i;  ca = [2+3i];

        static void func() {}
        void nest() {}
        fp = &func;  fps = [&func];
        dg = &nest;  dgs = [&nest];

        sx = S1X([1,2,3]);
        sy = S1Y(1024);

        aa1 = ["1":[1,2,3], "2":a.dup];
        static assert(!__traits(compiles, aa2 = ["x":a]));

        cat1 = [1,2] ~ [3,4] ~ a;
        cat2 = a ~ 1 ~ [2,3];
        cat3 = [1,2] ~ 3 ~ a;
        static assert(!__traits(compiles, cat4 = a ~ [[1]]));

        dotvar1 = S1X([1,2,3]).arr;
        dotvar2 = S1Y(1024).arr;

        slice1 = [1,2,3][2..$];
        slice2 = S1Y(1).arr[0..$-1];
    }
}

void test1()
{
              S1Z sm =           S1Z([1]);
        const S1Z sc =     const S1Z([1]);
    immutable S1Z si = immutable S1Z([1]);
    static assert(!__traits(compiles, { shared       S1Z ssm = shared       S1Z([]); }));
    static assert(!__traits(compiles, { shared const S1Z ssc = shared const S1Z([]); }));
}

/***************************************************/

template Rebindable(T) if (is(T == class)/* || is(T == interface) || isArray!T*/)
{
    static if (!is(T X == const U, U) && !is(T X == immutable U, U))
    {
        static assert(0);   // test
        alias T Rebindable;
    }
    //else static if (isArray!T)
    //{
    //    alias const(ElementType!T)[] Rebindable;
    //}
    else
    {
        pure nothrow
        struct Rebindable
        {
            private union
            {
                T original;
                U stripped;
            }

            this(inout T initializer) inout
            {
                original = initializer;
            }
            void opAssign(T another) @trusted
            {
                stripped = *cast(U*) &another;
            }
            void opAssign(Rebindable another) @trusted
            {
                stripped = another.stripped;
            }

            // safely construction/assignment
            // from Rebindable!(immutable U) to Rebindable!(const U)
            static if (is(T == const U))
            {
                this(Rebindable!(immutable U) another) inout
                {
                    original = another.original;
                }
                void opAssign(Rebindable!(immutable U) another)
                {
                    // safely assign immutable to const
                    stripped = another.stripped;
                }
            }

            // safely construction/assignment
            // from immutable Rebindable!(const U) to Rebindable!(immutable U)
            static if (is(T == immutable U))
            {
                this(immutable Rebindable!(const U) another) inout
                {
                    original = another.original;
                }
                void opAssign(immutable Rebindable!(const U) another) @trusted
                {
                    stripped = cast(U)another.stripped;
                }
            }

            @property ref inout(T) get() inout
            {
                return original;
            }
            alias get this;
        }
    }
}

void test2a()
{
    // this(inout T initializer) inout

    alias C = Object;
    alias R = Rebindable;

    C make(C)()
    {
        static int c; auto p = &c;  // mark impure
        return new C();
    }

    static assert( __traits(compiles, {           R!(    const C) r = make!(          C); }));  // this(    const C);   // OK
    static assert(!__traits(compiles, {           R!(immutable C) r = make!(          C); }));  // this(immutbale C);   // NG
    static assert( __traits(compiles, {           R!(    const C) r = make!(    const C); }));  // this(    const C);   // OK
    static assert(!__traits(compiles, {           R!(immutable C) r = make!(    const C); }));  // this(immutbale C);   // NG
    static assert( __traits(compiles, {           R!(    const C) r = make!(immutable C); }));  // this(    const C);   // OK
    static assert( __traits(compiles, {           R!(immutable C) r = make!(immutable C); }));  // this(immutbale C);   // OK

    static assert( __traits(compiles, {     const R!(    const C) r = make!(          C); }));  // this(    const C) const;   // OK
    static assert(!__traits(compiles, {     const R!(immutable C) r = make!(          C); }));  // this(immutbale C) const;   // NG
    static assert( __traits(compiles, {     const R!(    const C) r = make!(    const C); }));  // this(    const C) const;   // OK
    static assert(!__traits(compiles, {     const R!(immutable C) r = make!(    const C); }));  // this(immutbale C) const;   // NG
    static assert( __traits(compiles, {     const R!(    const C) r = make!(immutable C); }));  // this(    const C) const;   // OK
    static assert( __traits(compiles, {     const R!(immutable C) r = make!(immutable C); }));  // this(immutbale C) const;   // NG

    static assert(!__traits(compiles, { immutable R!(    const C) r = make!(          C); }));  // this(immutable C) immutable;   // NG
    static assert(!__traits(compiles, { immutable R!(immutable C) r = make!(          C); }));  // this(immutable C) immutable;   // NG
    static assert(!__traits(compiles, { immutable R!(    const C) r = make!(    const C); }));  // this(immutable C) immutable;   // NG
    static assert(!__traits(compiles, { immutable R!(immutable C) r = make!(    const C); }));  // this(immutable C) immutable;   // NG
    static assert( __traits(compiles, { immutable R!(    const C) r = make!(immutable C); }));  // this(immutable C) immutable;   // OK
    static assert( __traits(compiles, { immutable R!(immutable C) r = make!(immutable C); }));  // this(immutable C) immutable;   // OK
}

void test2b()
{
    alias C = Object;
    alias R = Rebindable;

    ref R make(R)()
    {
        static R r; // mark impure
        return r;   // enforce copying
    }

    static assert( __traits(compiles, {           R!(const C) r = make!(          R!(const C)); }));  // m -> m
    static assert( __traits(compiles, {     const R!(const C) r = make!(          R!(const C)); }));  // m -> c
    static assert(!__traits(compiles, { immutable R!(const C) r = make!(          R!(const C)); }));  // m -> i
    static assert( __traits(compiles, {           R!(const C) r = make!(    const R!(const C)); }));  // c -> m
    static assert( __traits(compiles, {     const R!(const C) r = make!(    const R!(const C)); }));  // c -> c
    static assert(!__traits(compiles, { immutable R!(const C) r = make!(    const R!(const C)); }));  // c -> i
    static assert( __traits(compiles, {           R!(const C) r = make!(immutable R!(const C)); }));  // i -> m
    static assert( __traits(compiles, {     const R!(const C) r = make!(immutable R!(const C)); }));  // i -> c
    static assert( __traits(compiles, { immutable R!(const C) r = make!(immutable R!(const C)); }));  // i -> i

    static assert( __traits(compiles, {           R!(immutable C) r = make!(          R!(immutable C)); }));  // m -> m
    static assert( __traits(compiles, {     const R!(immutable C) r = make!(          R!(immutable C)); }));  // m -> c
    static assert( __traits(compiles, { immutable R!(immutable C) r = make!(          R!(immutable C)); }));  // m -> i
    static assert( __traits(compiles, {           R!(immutable C) r = make!(    const R!(immutable C)); }));  // c -> m
    static assert( __traits(compiles, {     const R!(immutable C) r = make!(    const R!(immutable C)); }));  // c -> c
    static assert( __traits(compiles, { immutable R!(immutable C) r = make!(    const R!(immutable C)); }));  // c -> i
    static assert( __traits(compiles, {           R!(immutable C) r = make!(immutable R!(immutable C)); }));  // i -> m
    static assert( __traits(compiles, {     const R!(immutable C) r = make!(immutable R!(immutable C)); }));  // i -> c
    static assert( __traits(compiles, { immutable R!(immutable C) r = make!(immutable R!(immutable C)); }));  // i -> i
}

void test2c()
{
    alias C = Object;
    alias R = Rebindable;

    R make(R)()
    {
        static int c; auto p = &c;  // mark impure
        return R();
    }

    static assert( __traits(compiles, {           R!(const C) r = make!(          R!(immutable C)); }));  // m -> m
    static assert( __traits(compiles, {     const R!(const C) r = make!(          R!(immutable C)); }));  // m -> c
    static assert( __traits(compiles, { immutable R!(const C) r = make!(          R!(immutable C)); }));  // m -> i
    static assert( __traits(compiles, {           R!(const C) r = make!(    const R!(immutable C)); }));  // c -> m
    static assert( __traits(compiles, {     const R!(const C) r = make!(    const R!(immutable C)); }));  // c -> c
    static assert( __traits(compiles, { immutable R!(const C) r = make!(    const R!(immutable C)); }));  // c -> i
    static assert( __traits(compiles, {           R!(const C) r = make!(immutable R!(immutable C)); }));  // i -> m
    static assert( __traits(compiles, {     const R!(const C) r = make!(immutable R!(immutable C)); }));  // i -> c
    static assert( __traits(compiles, { immutable R!(const C) r = make!(immutable R!(immutable C)); }));  // i -> i

    static assert(!__traits(compiles, {           R!(immutable C) r = make!(          R!(const C)); }));  // m -> m
    static assert(!__traits(compiles, {     const R!(immutable C) r = make!(          R!(const C)); }));  // m -> c
    static assert(!__traits(compiles, { immutable R!(immutable C) r = make!(          R!(const C)); }));  // m -> i
    static assert(!__traits(compiles, {           R!(immutable C) r = make!(    const R!(const C)); }));  // c -> m
    static assert(!__traits(compiles, {     const R!(immutable C) r = make!(    const R!(const C)); }));  // c -> c
    static assert(!__traits(compiles, { immutable R!(immutable C) r = make!(    const R!(const C)); }));  // c -> i
    static assert( __traits(compiles, {           R!(immutable C) r = make!(immutable R!(const C)); }));  // i -> m
    static assert( __traits(compiles, {     const R!(immutable C) r = make!(immutable R!(const C)); }));  // i -> c
    static assert( __traits(compiles, { immutable R!(immutable C) r = make!(immutable R!(const C)); }));  // i -> i
}

void test2()
{
    test2a();
    test2b();
    test2c();
}

/**********************************/

int main()
{
    test8117();
    test9665();
    test11246();
    test1();
    test2();

    printf("Success\n");
    return 0;
}
