
extern(C) int printf(const char*, ...);

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
// 8864

struct BigInt8864
{
    int value;
    this(int n) { value = n; }
}

struct Nibble8864
{
    ubyte u;
    this(ubyte ub)
    in {
        assert(ub < 16);
    } body {
        this.u = ub;
    }
}

BigInt8864[] rx8864 = [1, 2];
enum BigInt8864[] cx8864 = [1, 2];
pragma(msg, cx8864);

Nibble8864[][] ra8864 = [[1, 2], [3, 4]];
enum Nibble8864[][] sa8864 = [[1, 2], [3, 4]];
pragma(msg, sa8864);

void test8864()
{
    BigInt8864[] ry8864 = [1, 2];
    enum BigInt8864[] sy8864 = [1, 2];
    pragma(msg, sy8864);

    Nibble8864[][] rb8864 = [[1, 2], [3, 4]];
    enum Nibble8864[][] sb8864 = [[1, 2], [3, 4]];
    pragma(msg, sb8864);

    class C1
    {
        BigInt8864[] rz8864 = [1, 2];
        enum BigInt8864[] sz8864 = [1, 2];
        pragma(msg, sz8864);
    }

    class C2
    {
        Nibble8864[][] rc8864 = [[1, 2], [3, 4]];
        enum Nibble8864[][] sc8864 = [[1, 2], [3, 4]];
        pragma(msg, sc8864);
    }
}

/***************************************************/

int main()
{
    test6475();
    test7019();
    test7239();
    test8123();
    test8147();
    test8410();
    test8864();

    printf("Success\n");
    return 0;
}
