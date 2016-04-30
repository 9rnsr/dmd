int g;

/*
TEST_OUTPUT:
---
====================
= test1 -> foo1
= foo1
= foo1 -> bar1
= bar1
= bar1 -> foo1
typeof foo1 = void function(int n) @system
typeof bar1 = void function(int n) @system
---
*/
void foo1()(int n)// @system
{
    pragma(msg, "= foo1");
    if (n > 0)
    {
        pragma(msg, "= foo1 -> bar1");
        bar1(n - 1);
    }
    return;
}

void bar1()(int n)
{
    pragma(msg, "= bar1");
    if (n > 0)
    {
        pragma(msg, "= bar1 -> foo1");
        foo1(n - 1);

        g = 1;
        (*cast(long*)&n) = 0;
        throw new Exception("");
    }
    return;
}

void test1() //@safe
{
    pragma(msg, "====================");
    pragma(msg, "= test1 -> foo1");
    foo1(5);

    pragma(msg, "typeof foo1 = ", typeof(&foo1!()));
    pragma(msg, "typeof bar1 = ", typeof(&bar1!()));
}

/*
TEST_OUTPUT:
---
====================
= test2 -> foo2
= foo2
= foo2 -> bar2
= bar2
= bar2 -> baz2
= baz2
= baz2 -> foo2
typeof foo2 = void function(int n) pure nothrow @nogc @safe
typeof bar2 = void function(int n) pure nothrow @nogc @safe
---
*/
void foo2()(int n)// @system
{
    pragma(msg, "= foo2");
    if (n > 0)
    {
        pragma(msg, "= foo2 -> bar2");
        bar2(n - 1);
    }
    return;
}

void bar2()(int n)
{
    pragma(msg, "= bar2");
    if (n > 0)
    {
        pragma(msg, "= bar2 -> baz2");
        baz2(n - 1);
    }
    return;
}

void baz2()(int n)
{
    pragma(msg, "= baz2");
    if (n > 0)
    {
        pragma(msg, "= baz2 -> foo2");
        foo2(n - 1);
        //g = 1;
        //(*cast(long*)&n) = 0;
        //throw new Exception("");
    }
    return;
}

void test2() //@safe
{
    pragma(msg, "====================");
    pragma(msg, "= test2 -> foo2");
    foo2(5);

    pragma(msg, "typeof foo2 = ", typeof(&foo2!()));
    pragma(msg, "typeof bar2 = ", typeof(&bar2!()));
}

/*
TEST_OUTPUT:
---
====================
= test3 -> foo3
= foo3
= foo3 -> bar3
= bar3
= bar3 -> baz3
= baz3
= baz3 -> bar3
typeof foo3 = void function(int n) pure nothrow @nogc @safe
typeof bar3 = void function(int n) pure nothrow @nogc @safe
---
*/
void foo3()(int n)// @system
{
    pragma(msg, "= foo3");
    if (n > 0)
    {
        pragma(msg, "= foo3 -> bar3");
        bar3(n - 1);
    }
    return;
}

void bar3()(int n)
{
    pragma(msg, "= bar3");
    if (n > 0)
    {
        pragma(msg, "= bar3 -> baz3");
        baz3(n - 1);
    }
    return;
}

void baz3()(int n)
{
    pragma(msg, "= baz3");
    if (n > 0)
    {
        pragma(msg, "= baz3 -> bar3");
        bar3(n - 1);
    }
    return;
}

void test3() //@safe
{
    pragma(msg, "====================");
    pragma(msg, "= test3 -> foo3");
    foo3(5);

    pragma(msg, "typeof foo3 = ", typeof(&foo3!()));
    pragma(msg, "typeof bar3 = ", typeof(&bar3!()));
}
