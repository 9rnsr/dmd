
extern(C) int printf(const char* fmt, ...);

template TypeTuple(T...){ alias T TypeTuple; }
template Id(      T){ alias T Id; }
template Id(alias A){ alias A Id; }

/***************************************************/

void test1()
{
    static class C1
    {
              void f1() {}
        const void f1() {}

              void f2() {}

              auto f3() { return &f1; }
        const auto f3() { return &f1; }
    }
    static class C2
    {
        const void f1() {}
              void f1() {}

              void f2() {}

        const auto f3() { return &f1; }
              auto f3() { return &f1; }
    }

    // FIX: the tolerance against C's member function declaration order
    foreach (C; TypeTuple!(C1, C2))
    {
        auto mc = new C;

        auto dg1 = &mc.f1;
        static assert(is(typeof(dg1) == void delegate()));

        auto dg2 = &mc.f2;
        static assert(is(typeof(dg2) == void delegate()));

        auto dg3 = &mc.f3;
        static assert(is(typeof(dg3) == void delegate() delegate()));
    }
    foreach (C; TypeTuple!(C1, C2))
    {
        const cc = new C;

        auto dg1 = &cc.f1;
        static assert(is(typeof(dg1) == void delegate() const));

        static assert(!is(typeof(&cc.f2)));

        auto dg3 = &cc.f3;
        static assert(is(typeof(dg3) == void delegate() const delegate() const));
    }
}

/***************************************************/

void test2()
{
    static class C1
    {
        bool f() const { return true; }
        void f(bool v) {}

               const void g1() {}
        shared const void g1() {}

               const int g2(int m)        { return 1; }
        shared const int g2(int m, int n) { return 2; }
    }
    static class C2
    {
        void f(bool v) {}
        bool f() const { return true; }

        shared const void g1() {}
               const void g1() {}

        shared const int g2(int m, int n) { return 2; }
               const int g2(int m)        { return 1; }
    }
    static bool g(bool v) { return v; }

    foreach (C; TypeTuple!(C1, C2))
    {
        auto mc = new C();
        assert(g(mc.f));

        auto ic = new immutable(C)();
        static assert(is(typeof(&ic.g1)));
        static assert(!__traits(compiles, typeof(&ic.g1)));

        assert(ic.g2(0) == 1);
        assert(ic.g2(0,0) == 2);

//        alias C.f foo;
//        static assert(is(typeof(foo)));
//        static assert(!__traits(compiles, typeof(foo)));
        // foo(==C.f) has ambiguous type, not exact type
    }
}

/***************************************************/
// 7418

int foo7418(uint a)   { return 1; }
int foo7418(char[] a) { return 2; }

alias foo7418 foo7418a;
template foo7418b(T = void) { alias foo7418 foo7418b; }

void test7418()
{
    assert(foo7418a(1U) == 1);
    assert(foo7418a("a".dup) == 2);

    assert(foo7418b!()(1U) == 1);
    assert(foo7418b!()("a".dup) == 2);
}

/***************************************************/
// 7552

struct S7552
{
    static void foo(){}
    static void foo(int){}
}

struct T7552
{
    alias TypeTuple!(__traits(getOverloads, S7552, "foo")) FooInS;
    alias FooInS[0] foo;    // should be S7552.foo()
    static void foo(string){}
}

struct U7552
{
    alias TypeTuple!(__traits(getOverloads, S7552, "foo")) FooInS;
    alias FooInS[1] foo;    // should be S7552.foo(int)
    static void foo(string){}
}

void test7552()
{
    alias TypeTuple!(__traits(getOverloads, S7552, "foo")) FooInS;
    static assert(FooInS.length == 2);
                                      FooInS[0]();
    static assert(!__traits(compiles, FooInS[0](0)));
    static assert(!__traits(compiles, FooInS[1]()));
                                      FooInS[1](0);

                                      Id!(FooInS[0])();
    static assert(!__traits(compiles, Id!(FooInS[0])(0)));
    static assert(!__traits(compiles, Id!(FooInS[1])()));
                                      Id!(FooInS[1])(0);

    alias TypeTuple!(__traits(getOverloads, T7552, "foo")) FooInT;
    static assert(FooInT.length == 2);                  // fail
                                      FooInT[0]();
    static assert(!__traits(compiles, FooInT[0](0)));
    static assert(!__traits(compiles, FooInT[0]("")));
    static assert(!__traits(compiles, FooInT[1]()));
    static assert(!__traits(compiles, FooInT[1](0)));   // fail
                                      FooInT[1]("");    // fail

    alias TypeTuple!(__traits(getOverloads, U7552, "foo")) FooInU;
    static assert(FooInU.length == 2);
    static assert(!__traits(compiles, FooInU[0]()));
                                      FooInU[0](0);
    static assert(!__traits(compiles, FooInU[0]("")));
    static assert(!__traits(compiles, FooInU[1]()));
    static assert(!__traits(compiles, FooInU[1](0)));
                                      FooInU[1]("");
}

/***************************************************/
// 8943

void test8943()
{
    struct S
    {
        void foo();
    }

    alias TypeTuple!(__traits(getOverloads, S, "foo")) Overloads;
    alias TypeTuple!(__traits(parent, Overloads[0])) P; // fail
    static assert(is(P[0] == S));
}

/***************************************************/
// 9410

struct S {}
int foo(float f, ref S s) { return 1; }
int foo(float f,     S s) { return 2; }
void test9410()
{
    S s;
    assert(foo(1, s  ) == 1); // works fine. Print: ref
    assert(foo(1, S()) == 2); // Fails with: Error: S() is not an lvalue
}

/***************************************************/

int main()
{
    test1();
    test2();
    test7418();
    test7552();
    test8943();
    test9410();

    printf("Success\n");
    return 0;
}
