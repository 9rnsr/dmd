
alias AliasSeq(T...) = T;

/***************************************************/

int foo1() { return 1; }
int foo1(int) { return 2; }

void test1()
{
    pragma(msg, foo1.mangleof);
    assert(foo1() == 1);
    assert(foo1(1) == 2);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo1"));
pragma(msg, ov);
    foreach (f; ov)
        pragma(msg, typeof(f));
}

/***************************************************/

int foo2() { return 1; }
int bar2(int) { return 2; }
alias foo2 = bar2;

void test2()
{
    pragma(msg, foo2.mangleof);
    assert(foo2() == 1);
    assert(foo2(1) == 2);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo2"));
pragma(msg, ov);
    foreach (f; ov)
        pragma(msg, typeof(f));
}

/***************************************************/

alias foo3 = bar3;
int bar3(int) { return 2; }
int foo3() { return 1; }

void test3()
{
    pragma(msg, foo3.mangleof);
    assert(foo3() == 1);
    assert(foo3(1) == 2);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo3"));
pragma(msg, ov);
    foreach (f; ov)
        pragma(msg, typeof(f));
}

/***************************************************/

alias foo4 = bar4;
int foo4() { return 1; }
int foo4(int) { return 2; }
int bar4(string) { return 3; }

void test4()
{
    pragma(msg, foo4.mangleof);
    assert(foo4() == 1);
    assert(foo4(1) == 2);
    assert(foo4("") == 3);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo4"));
pragma(msg, ov);
    foreach (f; ov)
        pragma(msg, typeof(f));
}

/***************************************************/

int bar5() { return 1; }
int bar5(int) { return 2; }
int foo5(string) { return 3; }
alias foo5 = bar5;

void test5()
{
pragma(msg, "====");
    pragma(msg, foo5.mangleof);
    assert(foo5() == 1);
    assert(foo5(1) == 2);
    assert(foo5("") == 3);

    alias ov = AliasSeq!(__traits(getOverloads, mixin(__MODULE__), "foo5"));
pragma(msg, ov);
    foreach (f; ov)
        pragma(msg, typeof(f));
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
