
alias AliasSeq(T...) = T;

/***************************************************/

int foo1() { return 1; }
int foo1(int) { return 2; }

void test1()
{
pragma(msg, "====");
    pragma(msg, foo1.mangleof);     static assert(foo1.mangleof == "9overload24foo1");
    assert(foo1() == 1);
    assert(foo1(1) == 2);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo1"));
    static assert(ov.length == 2);
//pragma(msg, ov);
//    foreach (f; ov)
//        pragma(msg, typeof(f));
    static assert(is(typeof(ov[0])* == int function()));
    static assert(is(typeof(ov[1])* == int function(int)));
}

/***************************************************/

int foo2() { return 1; }
int bar2(int) { return 2; }
alias foo2 = bar2;

void test2()
{
pragma(msg, "====");
    pragma(msg, foo2.mangleof);     static assert(foo2.mangleof == "9overload24foo2");
    assert(foo2() == 1);
    assert(foo2(1) == 2);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo2"));
    static assert(ov.length == 2);
//pragma(msg, ov);
//    foreach (f; ov)
//        pragma(msg, typeof(f));
    static assert(is(typeof(ov[0])* == int function()));
    static assert(is(typeof(ov[1])* == int function(int)));
}

/***************************************************/

alias foo3 = bar3;
int bar3(int) { return 2; }
int foo3() { return 1; }

void test3()
{
pragma(msg, "====");
    pragma(msg, foo3.mangleof);     static assert(foo3.mangleof == "9overload24foo3");
    assert(foo3() == 1);
    assert(foo3(1) == 2);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo3"));
    static assert(ov.length == 2);
//pragma(msg, ov);
//    foreach (f; ov)
//        pragma(msg, typeof(f));
    static assert(is(typeof(ov[0])* == int function(int)));
    static assert(is(typeof(ov[1])* == int function()));
}

/***************************************************/

alias foo4 = bar4;
int foo4() { return 1; }
int foo4(int) { return 2; }
int bar4(string) { return 3; }

void test4()
{
pragma(msg, "====");
    pragma(msg, foo4.mangleof);     static assert(foo4.mangleof == "9overload24foo4");
    assert(foo4() == 1);
    assert(foo4(1) == 2);
    assert(foo4("") == 3);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo4"));
    static assert(ov.length == 3);
//pragma(msg, ov);
//    foreach (f; ov)
//        pragma(msg, typeof(f));
    static assert(is(typeof(ov[0])* == int function(string)));
    static assert(is(typeof(ov[1])* == int function()));
    static assert(is(typeof(ov[2])* == int function(int)));
}

/***************************************************/

int bar5() { return 1; }
int bar5(int) { return 2; }
int foo5(string) { return 3; }
alias foo5 = bar5;

void test5()
{
pragma(msg, "====");
    pragma(msg, foo5.mangleof);     static assert(foo5.mangleof == "9overload24foo5");
    assert(foo5() == 1);
    assert(foo5(1) == 2);
    assert(foo5("") == 3);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo5"));
    static assert(ov.length == 3);
//pragma(msg, ov);
//    foreach (f; ov)
//        pragma(msg, typeof(f));
    static assert(is(typeof(ov[0])* == int function(string)));
    static assert(is(typeof(ov[1])* == int function()));
    static assert(is(typeof(ov[2])* == int function(int)));
}

/***************************************************/

alias foo6 = bar6;
int bar6() { return 1; }
int bar6(int) { return 2; }
alias foo6 = bar6;

void test6()
{
pragma(msg, "====");
    pragma(msg, foo6.mangleof);     static assert(foo6.mangleof == "9overload24foo6");
    assert(foo6() == 1);
    assert(foo6(1) == 2);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo6"));
    static assert(ov.length == 2);
//pragma(msg, ov);
//    foreach (f; ov)
//        pragma(msg, typeof(f));
    static assert(is(typeof(ov[0])* == int function()));
    static assert(is(typeof(ov[1])* == int function(int)));
}

/***************************************************/

void main()
{
    test1();
    test2();
    test3();
    test4();
    test5();
}
