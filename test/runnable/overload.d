
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

        alias C.f foo;
        static assert(is(typeof(foo)));
        static assert(!__traits(compiles, typeof(foo)));
    }
}

/***************************************************/

void test3()
{
    static class C
    {
        void f() {}
        void f(int n) {}

        // dummy functions to get type of f
        void f1() {}
        void f2(int n) {}
    }

    alias TypeTuple!(__traits(getOverloads, C, "f")) Fs;
    alias Fs[0] F1;
    alias Fs[1] F2;
    static assert(is(typeof(F1) == typeof(C.f1)));
    static assert(is(typeof(F2) == typeof(C.f2)));

    static assert(is(typeof(Id!F1) == typeof(C.f1)));
    static assert(is(typeof(Id!F2) == typeof(C.f2)));
    // ovrload resolution keeps through template alias parameter.

    foreach (i, F; __traits(getOverloads, C, "f"))
    {
        static if (i==0) static assert(is(typeof(F) == typeof(C.f1)));
        static if (i==1) static assert(is(typeof(F) == typeof(C.f2)));

        static if (i==0) static assert(is(typeof(Id!F) == typeof(C.f1)));
        static if (i==1) static assert(is(typeof(Id!F) == typeof(C.f2)));
    }
}

/***************************************************/

static int g(int n)        { return 1; }
static int g(int n, int m) { return 2; }

void test4()
{
    static class C
    {
        int f(int n)        { return 1; }
        int f(int n, int m) { return 2; }
    }
    auto c = new C();
    static assert(!__traits(compiles, (&c.f)()));
    assert((&c.f)(0) == 1);
    assert((&c.f)(0,1) == 2);

    static assert(!__traits(compiles, (&g)()));
    assert((&g)(0) == 1);
    assert((&g)(0,1) == 2);
}

/***************************************************/

struct Test5S
{
    void f(){}
    void f(int n){}
    void g()
    {
        // mtype.c L7107 TODO -> resloved
        //pragma(msg, typeof(Test5S.f));
        static assert(is(typeof(Test5S.f)));
        static assert(!__traits(compiles, typeof(Test5S.f)));
    }

    void h(){}
    void h(int n){}
}
class Test5C
{
    void f(){}
    void f(int n){}
    void g()
    {
        // mtype.c L7646 TODO -> resolved
        //pragma(msg, typeof(Test5C.f));
        static assert(is(typeof(Test5C.f)));
        static assert(!__traits(compiles, typeof(Test5C.f)));
    }

    class N
    {
        void x(){
            // mtype.c L7660 TODO -> resolved
            //pragma(msg, typeof(Test5C.f));
            static assert(is(typeof(Test5C.f)));
            static assert(!__traits(compiles, typeof(Test5C.f)));
        }
    }

}
void test5()
{
    Test5S s;
    s.g();
    // mtype.c L7145 TODO -> resolved
    //pragma(msg, typeof(s.h));
    static assert(is(typeof(s.h)));
    static assert(!__traits(compiles, typeof(s.h)));

    Test5C c = new Test5C();
    c.g();
    // mtype.c L7694 TODO -> resolved
    //pragma(msg, typeof(c.h));
    static assert(is(typeof(c.f)));
    static assert(!__traits(compiles, typeof(c.f)));
}

/***************************************************/

void test6()
{
    static class C
    {
        void f(){}
        void f(int n){}

        void f1(){}
        void f2(int n){}
    }
    alias C.f Fun;
    alias TypeTuple!(__traits(getOverloads, C, "f")) FunSeq;

    /*
        When template instantiates, overloaded symbol passed by FuncDeclaratioin.
        By the side, non overloaded symbol is passed by VarExp(var=fd, hasOverloads=0),
        and its type is same as fd->type.
    */

    static assert(is(typeof(C.f)));
    static assert(!__traits(compiles, typeof(C.f)));
    // direct

    static assert(is(typeof(Id!(C.f))));
    static assert(!__traits(compiles, typeof(Id!(C.f))));
    // direct -> through template alias parameter

    static assert(is(typeof(Fun)));
    static assert(!__traits(compiles, typeof(Fun)));
    // indirect(through alias)

    static assert(is(typeof(Id!(Fun))));
    static assert(!__traits(compiles, typeof(Id!(Fun))));
    // indirect -> through template alias parameter

    static assert(is(typeof(FunSeq[0]) == typeof(C.f1)));
    static assert(is(typeof(FunSeq[1]) == typeof(C.f2)));
    // direct(tuple element)

    static assert(is(typeof(Id!(FunSeq[0])) == typeof(C.f1)));
    static assert(is(typeof(Id!(FunSeq[1])) == typeof(C.f2)));
    // direct(tuple element) -> through template alias parameter
}

/***************************************************/

void test7()
{
    static class C
    {
        static int f()     { return 1; }
        static int f(int n){ return 2; }

        int f1()     { return 1; }
        int f2(int n){ return 2; }
    }
    alias C.f Fun;
    alias TypeTuple!(__traits(getOverloads, C, "f")) FunSeq;

    assert(C.f( ) == 1);
    assert(C.f(0) == 2);

    assert(Id!(C.f)( ) == 1);
    assert(Id!(C.f)(0) == 2);

    assert(FunSeq[0]( ) == 1);
    assert(FunSeq[1](0) == 2);
    static assert(!__traits(compiles, FunSeq[0](0) == 1));
    static assert(!__traits(compiles, FunSeq[1]( ) == 2));

    assert(Id!(FunSeq[0])( ) == 1);
    assert(Id!(FunSeq[1])(0) == 2);
    static assert(!__traits(compiles, Id!(FunSeq[0])(0) == 1));
    static assert(!__traits(compiles, Id!(FunSeq[1])( ) == 2));
}

/***************************************************/

class A8
{
    static int f(){ return 1; }
}
int g8(int n){ return 2; }
alias A8.f fun8;
alias g8 fun8;
void test8()
{
    assert(fun8( ) == 1);
    assert(fun8(0) == 2);
}

/***************************************************/

class A9
{
    static int f(){ return 1; }
}
class B9
{
    static int g(int n){ return 2; }
    alias A9.f fun;
    alias g fun;
}

void test9()
{
    assert(B9.fun( ) == 1);
    assert(B9.fun(0) == 2);
}

/***************************************************/

class A10
{
    static int f(){ return 1; }
    static int f(int n){ return 2; }
    alias TypeTuple!(__traits(getOverloads, A10, "f")) F;
    alias F[0] f0;
    alias F[1] f1;
}
class B10
{
    static int g(string s){ return 3; }
}

// int(), int(int), int(string)
alias A10.f fun10_1;
alias B10.g fun10_1;

// int(), int(string)
alias A10.F[0] fun10_2;
alias B10.g fun10_2;

// int(), int(int), int(string)
alias fun10_1 fun10_3;
alias fun10_2 fun10_3;

void test10()
{
    assert(fun10_1() == 1);
    assert(fun10_1(0) == 2);
    assert(fun10_1("s") == 3);

    assert(fun10_2() == 1);
    static assert(!__traits(compiles, fun10_2(0)));
    assert(fun10_2("s") == 3);

    assert(A10.f0() == 1);
    static assert(!__traits(compiles, A10.f0(0)));

    static assert(!__traits(compiles, A10.f1()));
    assert(A10.f1(0) == 2);

    assert(fun10_3() == 1);
    assert(fun10_3(0) == 2);
    assert(fun10_3("s") == 3);
}

/***************************************************/

void test11()
{
    static class C
    {
        static int f()     { return 1; }
        static int f(int n){ return 2; }

        alias TypeTuple!(f) L;
        alias L[0] F;
        // Keep overloads through template tuple parameter
    }

    alias C.L L;
    assert(L[0](0) == 2);
    assert(L[0]( ) == 1);
    static assert(!__traits( compiles,    typeof(L[0])  ));
    static assert( __traits( compiles, is(typeof(L[0])) ));
    // L[0] keeps overloaded f

    alias C.F F;
    assert(F(0) == 2);
    assert(F( ) == 1);
    static assert(!__traits( compiles,    typeof(F)  ));
    static assert( __traits( compiles, is(typeof(F)) ));
    // F keeps overloaded f

    alias TypeTuple!(__traits(getOverloads, C, "F")) Fs;
    assert(Fs[0]( ) == 1);
    assert(Fs[1](0) == 2);
    static assert(!__traits( compiles, Fs[0](0) ));
    static assert(!__traits( compiles, Fs[1]( ) ));
    // separate overloads from C.F <- C.L[0] <- TypeTuple!(C.f)[0]
}

/***************************************************/

void test12()
{
	// C.f prefers static functions, and c.f prefers virtual functions.

    int f1()        { return 0; }   alias typeof(f1) F1;
    int f2(int)     { return 0; }   alias typeof(f2) F2;
    int f3(string)  { return 0; }   alias typeof(f3) F3;
    int f4(int[])   { return 0; }   alias typeof(f4) F4;

    static class C1
    {
        int f()     { return 1; }
        int f(int)  { return 2; }
    }
    auto c1 = new C1();
    static assert(!__traits(compiles,            C1.f    (   )));
    static assert(!__traits(compiles,            C1.f    (100)));
    static assert(!__traits(compiles,        Id!(C1.f)   (   )));
    static assert(!__traits(compiles,        Id!(C1.f)   (100)));
    static assert(!__traits(compiles, TypeTuple!(C1.f)[0](   )));
    static assert(!__traits(compiles, TypeTuple!(C1.f)[0](100)));
    static assert(is(typeof(c1.f)) && !__traits(compiles, typeof(c1.f)));   // virtual ambiguous
    static assert(is(typeof(C1.f)) && !__traits(compiles, typeof(C1.f)));   // virtual ambiguous

    static class C2
    {
        int f()     { return 1; }
        int f(int)  { return 2; }
        static int f(string){ return 3; }
    }
    auto c2 = new C2();
    static assert(!__traits(compiles,            C2.f    (   )    ));
    static assert(!__traits(compiles,            C2.f    (100)    ));
           assert(                               C2.f    ("a") == 3);
    static assert(!__traits(compiles,        Id!(C2.f)   (   )    ));
    static assert(!__traits(compiles,        Id!(C2.f)   (100)    ));
           assert(                           Id!(C2.f)   ("a") == 3);
    static assert(!__traits(compiles, TypeTuple!(C2.f)[0](   )    ));
    static assert(!__traits(compiles, TypeTuple!(C2.f)[0](100)    ));
           assert(                    TypeTuple!(C2.f)[0]("a") == 3);
    static assert(is(typeof(c2.f)) && !__traits(compiles, typeof(c2.f)));   // virtual ambiguous
    static assert(is(typeof(C2.f) == F3));                                  // static  disambiguous

    static class C31
    {
        int f()     { return 1; }
        static int f(string){ return 3; }
    }
    auto c31 = new C31();
    static assert(!__traits(compiles,            C31.f    (100)    ));
           assert(                               C31.f    ("a") == 3);
    static assert(!__traits(compiles,        Id!(C31.f)   (100)    ));
           assert(                           Id!(C31.f)   ("a") == 3);
    static assert(!__traits(compiles, TypeTuple!(C31.f)[0](100)    ));
           assert(                    TypeTuple!(C31.f)[0]("a") == 3);
    static assert(is(typeof(c31.f) == F1));         // virtual disambiguous
    static assert(is(typeof(C31.f) == F3));         // static  disambiguous

    static class C32
    {
        int f()     { return 1; }
        int f(int)  { return 2; }
        static int f(string){ return 3; }
        static int f(int[]) { return 4; }
    }
    auto c32 = new C32();
    static assert(!__traits(compiles,            C32.f    (   )    ));
    static assert(!__traits(compiles,            C32.f    (100)    ));
           assert(                               C32.f    ("a") == 3);
           assert(                               C32.f    ([0]) == 4);
    static assert(!__traits(compiles,        Id!(C32.f)   (   )    ));
    static assert(!__traits(compiles,        Id!(C32.f)   (100)    ));
           assert(                           Id!(C32.f)   ("a") == 3);
           assert(                           Id!(C32.f)   ([0]) == 4);
    static assert(!__traits(compiles, TypeTuple!(C32.f)[0](   )    ));
    static assert(!__traits(compiles, TypeTuple!(C32.f)[0](100)    ));
           assert(                    TypeTuple!(C32.f)[0]("a") == 3);
           assert(                    TypeTuple!(C32.f)[0]([0]) == 4);
    static assert(is(typeof(c32.f)) && !__traits(compiles, typeof(c32.f))); // virtual ambiguous
    static assert(is(typeof(C32.f)) && !__traits(compiles, typeof(C32.f))); // static  ambiguous

    static class C4
    {
        int f()     { return 1; }
        static int f(string){ return 3; }
        static int f(int[]) { return 4; }
    }
    auto c4 = new C4();
    static assert(!__traits(compiles,            C4.f    (   )    ));
           assert(                               C4.f    ("a") == 3);
           assert(                               C4.f    ([0]) == 4);
    static assert(!__traits(compiles,        Id!(C4.f)   (   )    ));
           assert(                           Id!(C4.f)   ("a") == 3);
           assert(                           Id!(C4.f)   ([0]) == 4);
    static assert(!__traits(compiles, TypeTuple!(C4.f)[0](   )    ));
           assert(                    TypeTuple!(C4.f)[0]("a") == 3);
           assert(                    TypeTuple!(C4.f)[0]([0]) == 4);
    static assert(is(typeof(c4.f) == F1));                                  // virtual disambiguous
    static assert(is(typeof(C4.f)) && !__traits(compiles, typeof(C4.f)));   // static  ambiguous

    static class C5
    {
        static int f(string){ return 3; }
        static int f(int[]) { return 4; }
    }
    auto c5 = new C5();
    static assert(!__traits(compiles,            C5.f    (   )    ));
    static assert(!__traits(compiles,            C5.f    (100)    ));
    static assert(!__traits(compiles,        Id!(C5.f)   (   )    ));
    static assert(!__traits(compiles,        Id!(C5.f)   (100)    ));
    static assert(!__traits(compiles, TypeTuple!(C5.f)[0](   )    ));
    static assert(!__traits(compiles, TypeTuple!(C5.f)[0](100)    ));
    static assert(is(typeof(c5.f)) && !__traits(compiles, typeof(c5.f)));   // virtual ambiguous
    static assert(is(typeof(C5.f)) && !__traits(compiles, typeof(C5.f)));   // virtual ambiguous
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
    test3();
    test4();
    test5();
    test6();
    test7();
    test8();
    test9();
    test10();
    test11();
    test12();
    test7418();
    test7552();
    test8943();
    test9410();

    printf("Success\n");
    return 0;
}
