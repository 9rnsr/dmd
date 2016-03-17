// runnable/traits.d    9091,8972,8971,7027
// runnable/test4.d     test6()

extern(C) int printf(const char*, ...);

template TypeTuple(TL...) { alias TypeTuple = TL; }

/********************************************************/

mixin("struct S1 {"~aggrDecl1~"}");
mixin("class  C1 {"~aggrDecl1~"}");
enum aggrDecl1 =
q{
    alias Type = typeof(this);

    int x = 2;

    void foo()
    {
        static assert( is(typeof(Type.x.offsetof)));
        static assert( is(typeof(Type.x.mangleof)));
        static assert( is(typeof(Type.x.sizeof  )));
        static assert( is(typeof(Type.x.alignof )));
        static assert( is(typeof({ auto n = Type.x.offsetof; })));
        static assert( is(typeof({ auto n = Type.x.mangleof; })));
        static assert( is(typeof({ auto n = Type.x.sizeof;   })));
        static assert( is(typeof({ auto n = Type.x.alignof;  })));
        static assert( is(typeof(Type.x)));
        static assert( is(typeof({ auto n = Type.x; })));
        static assert( __traits(compiles, Type.x));
        static assert( __traits(compiles, { auto n = Type.x; }));

        static assert( is(typeof(x.offsetof)));
        static assert( is(typeof(x.mangleof)));
        static assert( is(typeof(x.sizeof  )));
        static assert( is(typeof(x.alignof )));
        static assert( is(typeof({ auto n = x.offsetof; })));
        static assert( is(typeof({ auto n = x.mangleof; })));
        static assert( is(typeof({ auto n = x.sizeof;   })));
        static assert( is(typeof({ auto n = x.alignof;  })));
        static assert( is(typeof(x)));
        static assert( is(typeof({ auto n = x; })));
        static assert( __traits(compiles, x));
        static assert( __traits(compiles, { auto n = x; }));

        with (this)
        {
            static assert( is(typeof(x.offsetof)));
            static assert( is(typeof(x.mangleof)));
            static assert( is(typeof(x.sizeof  )));
            static assert( is(typeof(x.alignof )));
            static assert( is(typeof({ auto n = x.offsetof; })));
            static assert( is(typeof({ auto n = x.mangleof; })));
            static assert( is(typeof({ auto n = x.sizeof;   })));
            static assert( is(typeof({ auto n = x.alignof;  })));
            static assert( is(typeof(x)));
            static assert( is(typeof({ auto n = x; })));
            static assert( __traits(compiles, x));
            static assert( __traits(compiles, { auto n = x; }));
        }
    }

    static void bar()
    {
        static assert( is(typeof(Type.x.offsetof)));
        static assert( is(typeof(Type.x.mangleof)));
        static assert( is(typeof(Type.x.sizeof  )));
        static assert( is(typeof(Type.x.alignof )));
        static assert( is(typeof({ auto n = Type.x.offsetof; })));
        static assert( is(typeof({ auto n = Type.x.mangleof; })));
        static assert( is(typeof({ auto n = Type.x.sizeof;   })));
        static assert( is(typeof({ auto n = Type.x.alignof;  })));
        static assert( is(typeof(Type.x)));
        static assert(!is(typeof({ auto n = Type.x; })));
        static assert( __traits(compiles, Type.x));
        static assert(!__traits(compiles, { auto n = Type.x; }));

        static assert( is(typeof(x.offsetof)));
        static assert( is(typeof(x.mangleof)));
        static assert( is(typeof(x.sizeof  )));
        static assert( is(typeof(x.alignof )));
        static assert( is(typeof({ auto n = x.offsetof; })));
        static assert( is(typeof({ auto n = x.mangleof; })));
        static assert( is(typeof({ auto n = x.sizeof;   })));
        static assert( is(typeof({ auto n = x.alignof;  })));
        static assert( is(typeof(x)));
        static assert(!is(typeof({ auto n = x; })));
        static assert( __traits(compiles, x));
        static assert(!__traits(compiles, { auto n = x; }));

        Type t;
        with (t)
        {
            static assert( is(typeof(x.offsetof)));
            static assert( is(typeof(x.mangleof)));
            static assert( is(typeof(x.sizeof  )));
            static assert( is(typeof(x.alignof )));
            static assert( is(typeof({ auto n = x.offsetof; })));
            static assert( is(typeof({ auto n = x.mangleof; })));
            static assert( is(typeof({ auto n = x.sizeof;   })));
            static assert( is(typeof({ auto n = x.alignof;  })));
            static assert( is(typeof(x)));
            static assert( is(typeof({ auto n = x; })));
            static assert( __traits(compiles, x));
            static assert( __traits(compiles, { auto n = x; }));
        }
    }
};
void test1()
{
    foreach (Type; TypeTuple!(S1, C1))
    {
        static assert( is(typeof(Type.x.offsetof)));
        static assert( is(typeof(Type.x.mangleof)));
        static assert( is(typeof(Type.x.sizeof  )));
        static assert( is(typeof(Type.x.alignof )));
        static assert( is(typeof({ auto n = Type.x.offsetof; })));
        static assert( is(typeof({ auto n = Type.x.mangleof; })));
        static assert( is(typeof({ auto n = Type.x.sizeof;   })));
        static assert( is(typeof({ auto n = Type.x.alignof;  })));
        static assert( is(typeof(Type.x)));
        static assert(!is(typeof({ auto n = Type.x; })));
        static assert( __traits(compiles, Type.x));
        static assert(!__traits(compiles, { auto n = Type.x; }));

        Type t;
        static assert( is(typeof(t.x.offsetof)));
        static assert( is(typeof(t.x.mangleof)));
        static assert( is(typeof(t.x.sizeof  )));
        static assert( is(typeof(t.x.alignof )));
        static assert( is(typeof({ auto n = t.x.offsetof; })));
        static assert( is(typeof({ auto n = t.x.mangleof; })));
        static assert( is(typeof({ auto n = t.x.sizeof;   })));
        static assert( is(typeof({ auto n = t.x.alignof;  })));
        static assert( is(typeof(t.x)));
        static assert( is(typeof({ auto n = t.x; })));
        static assert( __traits(compiles, t.x));
        static assert( __traits(compiles, { auto n = t.x; }));

        with (t)
        {
            static assert( is(typeof(x.offsetof)));
            static assert( is(typeof(x.mangleof)));
            static assert( is(typeof(x.sizeof  )));
            static assert( is(typeof(x.alignof )));
            static assert( is(typeof({ auto n = x.offsetof; })));
            static assert( is(typeof({ auto n = x.mangleof; })));
            static assert( is(typeof({ auto n = x.sizeof;   })));
            static assert( is(typeof({ auto n = x.alignof;  })));
            static assert( is(typeof(x)));
            static assert( is(typeof({ auto n = x; })));
            static assert( __traits(compiles, x));
            static assert( __traits(compiles, { auto n = x; }));
        }
    }
}

/********************************************************/

void test2()
{
    struct S
    {
        int val;
        int[] arr;
        int[int] aar;

        void foo() {}
        void boo()() {}

        static void test()
        {
            static assert(!__traits(compiles, S.foo()));
            static assert(!__traits(compiles, S.boo()));
            static assert(!__traits(compiles, foo()));
            static assert(!__traits(compiles, boo()));
        }
    }
    int v;
    int[] a;
    void f(int n) {}

    static assert( __traits(compiles, S.val));  // 'S.val' is treated just a symbol
    static assert(!__traits(compiles, { int n = S.val; }));
    static assert(!__traits(compiles, f(S.val)));

    static assert(!__traits(compiles, v = S.val) && !__traits(compiles, S.val = v));

    static assert(!__traits(compiles, 1 + S.val) && !__traits(compiles, S.val + 1));
    static assert(!__traits(compiles, 1 - S.val) && !__traits(compiles, S.val - 1));
    static assert(!__traits(compiles, 1 * S.val) && !__traits(compiles, S.val * 1));
    static assert(!__traits(compiles, 1 / S.val) && !__traits(compiles, S.val / 1));
    static assert(!__traits(compiles, 1 % S.val) && !__traits(compiles, S.val % 1));
    static assert(!__traits(compiles, 1 ~ S.arr) && !__traits(compiles, S.arr ~ 1));

    static assert(!__traits(compiles, 1 & S.val) && !__traits(compiles, S.val & 1));
    static assert(!__traits(compiles, 1 | S.val) && !__traits(compiles, S.val | 1));
    static assert(!__traits(compiles, 1 ^ S.val) && !__traits(compiles, S.val ^ 1));
    static assert(!__traits(compiles, 1 ~ S.val) && !__traits(compiles, S.val ~ 1));

    static assert(!__traits(compiles, 1 ^^ S.val) && !__traits(compiles, S.val ^^ 1));
    static assert(!__traits(compiles, 1 << S.val) && !__traits(compiles, S.val << 1));
    static assert(!__traits(compiles, 1 >> S.val) && !__traits(compiles, S.val >> 1));
    static assert(!__traits(compiles, 1 >>>S.val) && !__traits(compiles, S.val >>>1));
    static assert(!__traits(compiles, 1 && S.val) && !__traits(compiles, S.val && 1));
    static assert(!__traits(compiles, 1 || S.val) && !__traits(compiles, S.val || 1));
    static assert(!__traits(compiles, 1 in S.aar) && !__traits(compiles, S.val || [1:1]));

    static assert(!__traits(compiles, 1 <= S.val) && !__traits(compiles, S.val <= 1));
    static assert(!__traits(compiles, 1 == S.val) && !__traits(compiles, S.val == 1));
    static assert(!__traits(compiles, 1 is S.val) && !__traits(compiles, S.val is 1));

    static assert(!__traits(compiles, 1? 1:S.val) && !__traits(compiles, 1? S.val:1));
    static assert(!__traits(compiles, (1, S.val)) && !__traits(compiles, (S.val, 1)));

    static assert(!__traits(compiles, &S.val));
    static assert(!__traits(compiles, S.arr[0]) && !__traits(compiles, [1,2][S.val]));
    static assert(!__traits(compiles, S.val++) && !__traits(compiles, S.val--));
    static assert(!__traits(compiles, ++S.val) && !__traits(compiles, --S.val));

    static assert(!__traits(compiles, v += S.val) && !__traits(compiles, S.val += 1));
    static assert(!__traits(compiles, v -= S.val) && !__traits(compiles, S.val -= 1));
    static assert(!__traits(compiles, v *= S.val) && !__traits(compiles, S.val *= 1));
    static assert(!__traits(compiles, v /= S.val) && !__traits(compiles, S.val /= 1));
    static assert(!__traits(compiles, v %= S.val) && !__traits(compiles, S.val %= 1));
    static assert(!__traits(compiles, v &= S.val) && !__traits(compiles, S.val &= 1));
    static assert(!__traits(compiles, v |= S.val) && !__traits(compiles, S.val |= 1));
    static assert(!__traits(compiles, v ^= S.val) && !__traits(compiles, S.val ^= 1));
    static assert(!__traits(compiles, a ~= S.val) && !__traits(compiles, S.arr ~= 1));

    static assert(!__traits(compiles, v ^^= S.val) && !__traits(compiles, S.val ^^= 1));
    static assert(!__traits(compiles, v <<= S.val) && !__traits(compiles, S.val <<= 1));
    static assert(!__traits(compiles, v >>= S.val) && !__traits(compiles, S.val >>= 1));
    static assert(!__traits(compiles, v >>>=S.val) && !__traits(compiles, S.val >>>=1));

    static assert(!__traits(compiles, { auto x = 1 + S.val; }) && !__traits(compiles, { auto x = S.val + 1; }));
    static assert(!__traits(compiles, { auto x = 1 - S.val; }) && !__traits(compiles, { auto x = S.val - 1; }));
    static assert(!__traits(compiles, { auto x = S.arr ~ 1; }) && !__traits(compiles, { auto x = 1 ~ S.arr; }));

    static assert(!__traits(compiles, S.foo()));
    static assert(!__traits(compiles, S.boo()));
    S.test();
    alias foo = S.foo;
    alias boo = S.boo;
    static assert(!__traits(compiles, foo()));
    static assert(!__traits(compiles, boo()));

//  static assert(S.val);

    struct SW { int a; }
    class CW { int a; }
    static assert(!__traits(compiles, { with (SW) { int n = a; } }));
    static assert(!__traits(compiles, { with (CW) { int n = a; } }));
}

/********************************************************/

struct S3
{
    struct T3 { int val; void foo() {} }
    T3 member;
    alias member this;

    static void test()
    {
        static assert(!__traits(compiles,   S3.val = 1   ));
        static assert(!__traits(compiles, { S3.val = 1; }));
        static assert(!__traits(compiles,   T3.val = 1   ));
        static assert(!__traits(compiles, { T3.val = 1; }));
        static assert(!__traits(compiles,   __traits(getMember, S3, "val") = 1   ));
        static assert(!__traits(compiles, { __traits(getMember, S3, "val") = 1; }));
        static assert(!__traits(compiles,   __traits(getMember, T3, "val") = 1   ));
        static assert(!__traits(compiles, { __traits(getMember, T3, "val") = 1; }));

        static assert(!__traits(compiles,   S3.foo()   ));
        static assert(!__traits(compiles, { S3.foo(); }));
        static assert(!__traits(compiles,   T3.foo()   ));
        static assert(!__traits(compiles, { T3.foo(); }));
        static assert(!__traits(compiles,   __traits(getMember, S3, "foo")()   ));
        static assert(!__traits(compiles, { __traits(getMember, S3, "foo")(); }));
        static assert(!__traits(compiles,   __traits(getMember, T3, "foo")()   ));
        static assert(!__traits(compiles, { __traits(getMember, T3, "foo")(); }));
        static assert(!__traits(compiles,   __traits(getOverloads, S3, "foo")[0]()   ));
        static assert(!__traits(compiles, { __traits(getOverloads, S3, "foo")[0](); }));
        static assert(!__traits(compiles,   __traits(getOverloads, T3, "foo")[0]()   ));
        static assert(!__traits(compiles, { __traits(getOverloads, T3, "foo")[0](); }));
    }
}

void test3()
{
}

/********************************************************/

void test4()
{
    static struct R
    {
        void opIndex(int) {}
        void opSlice() {}
        void opSlice(int, int) {}
        int opDollar() { return 1; }
        alias length = opDollar;
    }

    R val;
    static struct S
    {
        R val;
        void foo()
        {
            static assert(__traits(compiles, val[1]));              // TypeSArray
            static assert(__traits(compiles, val[]));               // TypeDArray
            static assert(__traits(compiles, val[0..val.length]));  // TypeSlice
        }
    }
}

/********************************************************/

template Test5(string name, bool result)
{
    mixin(`static assert(__traits(compiles, `~name~`.add!"months"(1)) == result);`);
}

static struct Begin5
{
    void add(string s)(int n) {}
}

struct IntervalX5(TP)
{
    Begin5 begin;

    static assert(__traits(compiles, begin.add!"months"(1)) == true);
    mixin Test5!("begin", true);

    void foo()
    {
        static assert(__traits(compiles, begin.add!"months"(1)) == true);
        mixin Test5!("begin", true);
    }
    static test()
    {
        static assert(__traits(compiles, begin.add!"months"(1)) == false);
        mixin Test5!("begin", false);
    }
}

alias IX5 = IntervalX5!int;
alias beginX5 = IX5.begin;
static assert(__traits(compiles, beginX5.add!"months"(1)) == false);
mixin Test5!("beginG5", false);

void test5()
{
    static struct IntervalY5(TP)
    {
        Begin5 begin;

        static assert(__traits(compiles, begin.add!"months"(1)) == true);
        mixin Test5!("begin", true);

        void foo()
        {
            static assert(__traits(compiles, begin.add!"months"(1)) == true);
            mixin Test5!("begin", true);
        }
        static test()
        {
            static assert(__traits(compiles, begin.add!"months"(1)) == false);
            mixin Test5!("begin", false);
        }
    }

    alias IX = IntervalX5!int;
    alias beginX = IX.begin;
    static assert(__traits(compiles, beginX.add!"months"(1)) == false);
    mixin Test5!("beginX", false);

    alias IY = IntervalY5!int;
    alias beginY = IY.begin;
    static assert(__traits(compiles, beginY.add!"months"(1)) == false);
    mixin Test5!("beginY", false);
}

/********************************************************/

void test6()
{
    static struct Foo
    {
        static struct Bar
        {
            static int get() { return 0; }
            static int val;
            void set() { assert(0); }
            int num;
        }
        static class Baz
        {
            static int get() { return 0; }
            static int val;
            void set() { assert(0); }
            int num;
        }
        Bar bar;
        Baz baz;
    }

    // allowed cases that do 'use' Foo.bar without this
    assert(Foo.bar.get() == 0);         // Foo.bar.get()
    assert(Foo.baz.get() == 0);         // Foo.bar.get()
    static assert(!__traits(compiles, Foo.bar.set()));
    static assert(!__traits(compiles, Foo.baz.set()));

    assert(Foo.bar.val == 0);           // Foo.bar.val
    assert(Foo.baz.val == 0);           // Foo.baz.val
    static assert(!__traits(compiles, Foo.bar.num = 1));
    static assert(!__traits(compiles, Foo.baz.num = 1));
}

/********************************************************/

struct Tuple7(T...)
{
    T field;

    enum check1 = is(typeof(field[0] = 1));
    enum check2 = is(typeof({ field[0] = 1; }));

    this(U, size_t n)(U[n] values)
    if (is(typeof({ foreach (i, _; T) field[0] = values[0]; })))
    {}
}

void test7()
{
    alias Tuple7!(int, int) Tup7;
    static assert(Tup7.check1);
    static assert(Tup7.check2);
    int[2] ints = [ 1, 2 ];
    Tup7 t = ints;

    struct S7
    {
        int value;

        enum check1 = is(typeof(value = 1));
        enum check2 = is(typeof({ value = 1; }));

        void foo()(int v)
        if (is(typeof({
            value = v;  // valid
        }))) {}

        static void bar()(int v)
        if (is(typeof({
            value = v;  // always invalid
        }))) {}
    }
    static assert(S7.check1);
    static assert(S7.check2);
    S7 s;
    s.foo(1);
    static assert(!__traits(compiles, S7.bar(1)));
}

/********************************************************/
// 4350

template Mix4350() { int b; }

struct S4350
{
    int a;

    mixin Mix4350 mix;

    int c;
    template Func() { void call(int n) { c = n; } }
    alias func = Func!();
}

void test4350()
{
    S4350 s;

    s.a = 1;
    s.mix.b = 2;
    s.func.call(3);
    assert(s.a == 1);
    assert(s.b == 2);
    assert(s.c == 3);

    with (s) { a = 2; }
    with (s) { mix.b = 3; }
    with (s) { func.call(4); }
    assert(s.a == 2);
    assert(s.b == 3);
    assert(s.c == 4);
}

/********************************************************/
// 6430

auto bug6430(int a)
{
    static struct Result2 {}
    return 4;
}
auto bug6430(int a, int b)
{
    static struct Result2
    {
        int z;
        int y() { return z; }
    }
    auto t = Result2(1);
    return 5;
}

/********************************************************/
// 9439

class B9439
{
    int boo(alias F)()
    {
        return F();
    }
}

class D9439 : B9439
{
    int foo() { return 1; }
    int bug()
    {
        return boo!(foo)();
    }
}

void test9439()
{
    auto d = new D9439();
    assert(d.bug() == 1);;
}

/********************************************************/

struct ShiftOr//(Char)
{
    static struct ShiftThread
    {
        void setInvMask()
        {
        }

        void set(alias setBits = setInvMask)(dchar ch)
        {
        }

        void add(dchar ch) { return set!setInvMask(ch); }
    }
}

/********************************************************/
// 9619

struct Foo9619 { int x; }
void test9619()
{
    void bar()
    {
        typeof(Foo9619.x) y;
    }
}

/********************************************************/
// 9633

class Foo9633
{
    void baz() {}
    void bar()
    {
        // CallExp::e1->op == TOKvar
        static assert( compilesWithoutThis9633!baz);
    }
    void vaz()()
    {
        static class C
        {
            // CallExp::e1->op == TOKtemplate
            static assert(!__traits(compiles, vaz()));
        }
    }
}

template compilesWithoutThis9633(alias F)
{
    enum bool compilesWithoutThis9633 = __traits(compiles, F());
}

void test9633()
{
    auto foo = new Foo9633;
    foo.bar();
    foo.vaz();
}

/********************************************************/
// 11245

struct Vec11245
{
    float[2] f;
}

class Bar11245
{
    void func()
    {
        float[Vec11245.f.length] newVal;
    }
}

/********************************************************/
// 11614

struct Tuple11614(T...)
{
    T field;
    alias field this;
}

struct Foo11614
{
    alias Tuple11614!(int) NEW_ARGS;

    NEW_ARGS args;

    void foo()
    {
        static if (NEW_ARGS.length == 1)
        {}
        else
            static assert(0);
    }
}

/********************************************************/
// 11993

struct S11993
{
    void foo()() const
    if (is(typeof(this) == const(S11993)))
    {}

    const void bar()()
    if (is(typeof(this) == const(S11993)))
    {}
}

void test11993()
{
    S11993 s;
    s.foo();
    s.bar();
}

/********************************************************/
// 12285

struct S12285
{
    int a, c;

    template toA(alias s)
    {
        void copy()
        {
            a = s;
        }
    }

    alias cToA = toA!c;
}

void test12285()
{
    S12285 s;
    s.c = 42;
    s.cToA.copy();
    assert(s.a == 42);
}

/********************************************************/
// 12286

class A12286          { int i; }
class B12286 : A12286 { int j; }

template copy12286(alias a, alias b)
{
    void copy12286() { a = b; }
}

class C12286 : B12286
{
    // The alias copyIJ works as C's member funciton
    alias copyIJ = copy12286!(i, j);
}

void test12286()
{
    auto c = new C12286();
    c.i = 1;
    c.j = 2;
    c.copyIJ();
    assert(c.i == 2);
}

/********************************************************/
// 14848

template OffsetOf14848(alias member)
{
    size_t get() { return member.offsetof; }
}

void test14848()
{
    static struct S { int v; }

    auto i = OffsetOf14848!(S.v).get();
    assert(i == S.v.offsetof);
}

/********************************************************/
// 15734

template map15734(alias fun)
{
    auto map15734(R)(R r)
    {
        return MapResult15734!(fun, R)(r);
    }
}

struct MapResult15734(alias fun, R)
{
    R _input;

    @property empty() const
    {
        return _input.length == 0;
    }

    @property auto ref front()
    {
        return fun(_input[0]);
    }

    void popFront()
    {
        _input = _input[1 .. $];
    }
}

class C15734
{
    int n;

    int foo(int a)
    {
        return a * n;
    }

    int[] test()
    {
        n = 3;
        int[] r;
        foreach (e; map15734!foo([ 1, 2, 3 ]))
            r ~= e;
        return r;
    }
}

void test15734()
{
    assert(new C15734().test() == [3, 6, 9]);
}

/********************************************************/
// 12230

static template T12230a(alias a)
{
    // this should become member function?
    auto foo() { return a * 2; }
}

struct S12230a
{
    int i = 2;
    @property int p() { return 3; }

    alias ti = T12230a!i;  // OK
    alias tp = T12230a!p;  // OK <- Error
}

void test12230a()
{
    S12230a s;
    assert(s.ti.foo() == 4);
    assert(s.tp.foo() == 6);
}

static template T12230b(alias a, alias anchor = Object)
{
    auto foo() { return a * 2; }
}

struct ST12230b
{
    int i = 2;
    @property int p() { return 3; }

    alias ti = T12230b!(i);    // bound to S implicitly
    alias tp = T12230b!(p, i); // bound to S via anchor
}

void test12230b()
{
    ST12230b s;
    assert(s.ti.foo() == 4);
    assert(s.tp.foo() == 6);
}

/********************************************************/

void testBinaryHeap()
{
    int less(int, int) { return 1; }

    // The instantiated struct BinaryHeap!less.BinaryHeap is made nested in its semantic()
    auto heap = BinaryHeap!(less)();
    heap.acquire();
}

struct BinaryHeap(alias less = "a < b")
{
    // In HeapOps!less.hasNestedArgs, the isNeedThisScope call will reach to
    // the testBinaryHeap function via BinaryHeap.vthis, then the instance
    // will also become nested.
    alias buildHeap = HeapOps!(less).buildHeap;

    void acquire()
    {
        buildHeap();
    }
}

template HeapOps(alias less)
{
    alias lessFun = /*binaryFun!*/less;

    void buildHeap()()
    {
        // finally lessFun call can get correct enclosing context.
        if (lessFun(1, 2)) {}
    }
}

/********************************************************/

@safe void testLevenshteinDistance()
{
    assert(levenshteinDistance("cat", "rat") == 1);
}

size_t levenshteinDistance(alias equals = (a,b) => a == b, R1, R2)(R1 s, R2 t)
{
    alias eq = equals;

    Levenshtein!(R1, eq, size_t) lev;
    return 0;
}

private struct Levenshtein(Range, alias equals, CostType = size_t)
{
    ~this() {}
}

/********************************************************/

void isPrettyPropertyName(in char[] name)
{
    auto names = [
        "L", "Letter",
    ];
    find!(x => (x == name) == 0)(names);
}

auto find(alias pred, R)(R haystack)
{
    if (pred(haystack[0])) {}
}

/********************************************************/

int main()
{
    test1();
    test2();
    test3();
    test4();
    test5();
    test6();
    test7();
    test4350();
    test9439();
    test9619();
    test9633();
    test12285();
    test12286();
    test14848();
    test15734();
    test12230a();
    test12230b();

    printf("Success\n");
    return 0;
}
