
extern(C) int printf(const char*, ...);

/***************************************************/
// 6469

void test6469()
{
    /* Multidimensional block initializing */

    // '1' matches to int
    int[2][2] a1 = 1;
    assert(a1 == [[1,1], [1,1]]);

    // 'sa' matches to int[3]
    int[3] sa = [1,2,3];
    int[3][3] a2 = sa;
    assert(a2 == [[1,2,3], [1,2,3], [1,2,3]]);

    // '[1,2]' matches to int[3], but element number mismatch occurs.
    static assert(!__traits(compiles, { int[3][3] a = [1,2]; }));

    // '[1,2]' matches to int[]
    int[][3] a3 = [1,2];
    assert(a3 == [[1,2], [1,2], [1,2]]);
    assert(a3[0] is a3[1] && a3[1] is a3[2]);

    // '[1,2]' cannot match to both int[][] and int[][][3]
    static assert(!__traits(compiles, { int[][][3] a = [1,2]; }));

    // '[[1],[2]]' matches to int[1][2]
    int[1][2][3] a4 = [[1],[2]];
    assert(a4 == [[[1],[2]], [[1],[2]], [[1],[2]]]);

    /* ArrayInitializer with heterogeneous elements */

    // '1' and '[2]' match to int[1], then '[1, [2]]' matches to int[1][2]
    int[1][2] a5 = [1, [2]];
    assert(a5 == [[1], [2]]);

    // '1' and '[2]' match to int[1], then '[1, [2]]' matches to int[1][2]
    int[1][2][3] a6 = [1, [2]];
    assert(a6 == [[[1], [2]], [[1], [2]], [[1], [2]]]);

    // '1' and '[2]' match to int[1], then '[1, [2]]' matches to int[1][2]
    int[1][2][2][2] a6x = [1, [2]];
    assert(a6x == [[[[1], [2]], [[1], [2]]], [[[1], [2]], [[1], [2]]]]);

    /* Implicit constructor call */

    struct S { this(int n) { num = n; } int num; }

    // '1', '2', and '3' cannot match to S, then semantic analysis will try
    // to fit '[1,2,3]' to S[3], and invokes implicit ctor call for the
    // ArrayInitializer elements.
    S[3] a7 = [1, 2, 3];
    assert(a7 == [S(1), S(2), S(3)]);

    // '1' cannot match to S, and element number mismatch occurs (3 vs 2).
    static assert(!__traits(compiles, { S[3] a = [1, 1]; }));

    /* Actual cases from issues */

    // 6469
    int[int][int] aa1 = [30: [10: 1, 20: 2]];
    int[char][char] aa2 = ['A': ['B': 1]];
    string[string][string] aa3 = ["one" : ["a":"A", "b":"B"]];

    // 9520
    struct Foo { int[int][char] aa; }
    Foo   foo1 =  { ['A': [0:10, 1:20]] };
    Foo[] foo2 = [{ ['A': [0:10, 1:20]] }, { ['B': [9:40, 10:30]] }];

    // 12787
    int[][char][][int] table = [1000:[['a':[1,2,3],'b':[2,3,4]]]];

    // 8864
    struct Nibble
    {
        ubyte u;
        this(ubyte ub) { this.u = ub; }
    }
    Nibble[] data1 = [5, 6];
    assert(data1 == [Nibble(5), Nibble(6)]);
    Nibble[][3] data2 = [[1,2], [3], [4,5,6]];
    assert(data2 == [[Nibble(1), Nibble(2)], [Nibble(3)], [Nibble(4), Nibble(5), Nibble(6)]]);

    testX();
}

void testX()
{
    static ubyte[] foo() { return [1,2]; }
    static ubyte[2] b1 = foo();
    assert(b1 == [1,2]);

    ubyte[] a = [1,2];
    size_t i;
    ubyte[2] b2 = a[i .. i+2];
    assert(b2 == [1,2]);
}

void testy()
{
    struct S
    {
        int a;

        static S opCall(int i)
        {
            S s;
            s.a = i;
            return s;
        }
    }

    S s = 3;
    static assert(!__traits(compiles, { static S gs = 3; }));
}

/***************************************************/
// 6475

class Foo6475(Value)
{
    template T1(size_t n){ alias int T1; }
}

void test6475()
{
    alias Foo6475!(int) C1;
    alias C1.T1!0 X1;
    static assert(is(X1 == int));

    alias const(Foo6475!(int)) C2;
    alias C2.T1!0 X2;
    static assert(is(X2 == int));
}

/***************************************************/
// 6905

void test6905()
{
    auto foo1() { static int n; return n; }
    auto foo2() {        int n; return n; }
    auto foo3() {               return 1; }
    static assert(typeof(&foo1).stringof == "int delegate()");
    static assert(typeof(&foo2).stringof == "int delegate()");
    static assert(typeof(&foo3).stringof == "int delegate()");

    ref bar1() { static int n; return n; }
  static assert(!__traits(compiles, {
    ref bar2() {        int n; return n; }
  }));
  static assert(!__traits(compiles, {
    ref bar3() {               return 1; }
  }));

    auto ref baz1() { static int n; return n; }
    auto ref baz2() {        int n; return n; }
    auto ref baz3() {               return 1; }
    static assert(typeof(&baz1).stringof == "int delegate() ref");
    static assert(typeof(&baz2).stringof == "int delegate()");
    static assert(typeof(&baz3).stringof == "int delegate()");
}

/***************************************************/
// 7019

struct S7019
{
    int store;
    this(int n)
    {
        store = n << 3;
    }
}

S7019 rt_gs = 2;
enum S7019 ct_gs = 2;
pragma(msg, ct_gs, ", ", ct_gs.store);

void test7019()
{
    S7019 rt_ls = 3; // this compiles fine
    enum S7019 ct_ls = 3;
    pragma(msg, ct_ls, ", ", ct_ls.store);

    static class C
    {
        S7019 rt_fs = 4;
        enum S7019 ct_fs = 4;
        pragma(msg, ct_fs, ", ", ct_fs.store);
    }

    auto c = new C;
    assert(rt_gs == S7019(2) && rt_gs.store == 16);
    assert(rt_ls == S7019(3) && rt_ls.store == 24);
    assert(c.rt_fs == S7019(4) && c.rt_fs.store == 32);
    static assert(ct_gs == S7019(2) && ct_gs.store == 16);
    static assert(ct_ls == S7019(3) && ct_ls.store == 24);
    static assert(C.ct_fs == S7019(4) && C.ct_fs.store == 32);

    void foo(S7019 s = 5)   // fixing bug 7152
    {
        assert(s.store == 5 << 3);
    }
    foo();
}

/***************************************************/
// 7239

struct vec7239
{
    float x, y, z, w;
    alias x r;  //! for color access
    alias y g;  //! ditto
    alias z b;  //! ditto
    alias w a;  //! ditto
}

void test7239()
{
    vec7239 a = {x: 0, g: 0, b: 0, a: 1};
    assert(a.r == 0);
    assert(a.g == 0);
    assert(a.b == 0);
    assert(a.a == 1);
}

/***************************************************/
// 10635

struct S10635
{
    string str;

    this(string[] v) { str = v[0]; }
    this(string[string] v) { str = v.keys[0]; }
}

S10635 s10635a = ["getnonce"];
S10635 s10635b = ["getnonce" : "str"];

void test10635()
{
    S10635 sa = ["getnonce"];
    S10635 sb = ["getnonce" : "str"];
}

/***************************************************/
// 8123

void test8123()
{
    struct S { }

    struct AS
    {
        alias S Alias;
    }

    struct Wrapper
    {
        AS as;
    }

    Wrapper w;
    static assert(is(typeof(w.as).Alias == S));         // fail
    static assert(is(AS.Alias == S));                   // ok
    static assert(is(typeof(w.as) == AS));              // ok
    static assert(is(typeof(w.as).Alias == AS.Alias));  // fail
}

/***************************************************/
// 8147

enum A8147 { a, b, c }

@property ref T front8147(T)(T[] a)
if (!is(T[] == void[]))
{
    return a[0];
}

template ElementType8147(R)
{
    static if (is(typeof({ R r = void; return r.front8147; }()) T))
        alias T ElementType8147;
    else
        alias void ElementType8147;
}

void test8147()
{
    auto arr = [A8147.a];
    alias typeof(arr) R;
    auto e = ElementType8147!R.init;
}

/***************************************************/
// 8410

void test8410()
{
    struct Foo { int[15] x; string s; }

    Foo[5] a1 = Foo([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], "hello"); // OK
    Foo f = { s: "hello" }; // OK (not static)
    Foo[5] a2 = { s: "hello" }; // error
}

/***************************************************/
// 8942

alias const int A8942_0;
static assert(is(A8942_0 == const int)); // passes

void test8942()
{
    alias const int A8942_1;
    static assert(is(A8942_1 == const int)); // passes

    static struct S { int i; }
    foreach (Unused; typeof(S.tupleof))
    {
        alias const(int) A8942_2;
        static assert(is(A8942_2 == const int)); // also passes

        alias const int A8942_3;
        static assert(is(A8942_3 == const int)); // fails
        // Error: static assert  (is(int == const(int))) is false
    }
}

/***************************************************/
// 10144

final class TNFA10144(char_t)
{
    enum Act { don }
    const Act[] action_lookup1 = [ Act.don, ];
}
alias X10144 = TNFA10144!char;

class C10144
{
    enum Act { don }
    synchronized { enum x1 = [Act.don]; }
    override     { enum x2 = [Act.don]; }
    abstract     { enum x3 = [Act.don]; }
    final        { enum x4 = [Act.don]; }
    synchronized { static s1 = [Act.don]; }
    override     { static s2 = [Act.don]; }
    abstract     { static s3 = [Act.don]; }
    final        { static s4 = [Act.don]; }
    synchronized { __gshared gs1 = [Act.don]; }
    override     { __gshared gs2 = [Act.don]; }
    abstract     { __gshared gs3 = [Act.don]; }
    final        { __gshared gs4 = [Act.don]; }
}

/***************************************************/

// 10142

class File10142
{
    enum Access : ubyte { Read = 0x01 }
    enum Open : ubyte { Exists = 0 }
    enum Share : ubyte { None = 0 }
    enum Cache : ubyte { None = 0x00 }

    struct Style
    {
        Access  access;
        Open    open;
        Share   share;
        Cache   cache;
    }
    enum Style ReadExisting = { Access.Read, Open.Exists };

    this (const(char[]) path, Style style = ReadExisting)
    {
        assert(style.access == Access.Read);
        assert(style.open   == Open  .Exists);
        assert(style.share  == Share .None);
        assert(style.cache  == Cache .None);
    }
}

void test10142()
{
    auto f = new File10142("dummy");
}

/***************************************************/
// 11421

void test11421()
{
    // AAs in array
    const            a1 = [[1:2], [3:4]];   // ok <- error
    const int[int][] a2 = [[1:2], [3:4]];   // ok
    static assert(is(typeof(a1) == typeof(a2)));

    // AAs in AA
    auto aa = [1:["a":1.0], 2:["b":2.0]];
    static assert(is(typeof(aa) == double[string][int]));
    assert(aa[1]["a"] == 1.0);
    assert(aa[2]["b"] == 2.0);
}

/***************************************************/

int main()
{
    test6469();
    test6475();
    test6905();
    test7019();
    test7239();
    test8123();
    test8147();
    test8410();
    test8942();
    test10142();
    test11421();

    printf("Success\n");
    return 0;
}
