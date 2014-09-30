//import std.stdio;
extern(C) int printf(const char*, ...);

void test1()
{
    int delegate()[] a;
    foreach (i; 1 .. 10)
    {
        a ~= { printf("%d\n", i); return i; };
        //void foo() { printf("%d\n", i); } foo();    // OK
        //auto p = &foo;                            // NG
    }

    int i = 1;
    foreach (f; a)
    {
        assert(f() == i++);
    }
}


void test2()
{
    int delegate()[] a;
    foreach (i; 1 .. 10)
    {
        foreach (j; 1 .. 10)
        {
            a ~= { /*printf("(i, j) = (%d, %d)\n", i, j); */return i * 10 + j; };
        }
    }

    int ij = 11;
    foreach (f; a)
    {
        assert(f() == ij++);
        if (ij % 10 == 0)
            ++ij;
    }
}

void test3()
{
    int delegate()[] a;
    foreach (i; 1 .. 10)
    {
        int j = 9; // should be loop closure
        a ~= { /*printf("(i, j) = (%d, %d)\n", i, j); */return i * 10 + j; };
    }

    int ij = 19;
    foreach (f; a)
    {
        assert(f() == ij);
        ij += 10;
    }
}

void test4()
{
    int delegate()[] a;
    foreach (i; 1 .. 10)
    {
        int j = i * 10 + 9; // should be loop closure?
        a ~= { /*printf("j = %d\n", j); */return j; };
    }

    int j = 19;
    foreach (f; a)
    {
        assert(f() == j);
        j += 10;
    }
}

void test4x()
{
    int delegate()[] a;
    for (size_t i = 1; i < 10; i++)
    {
        int j = i * 10 + 9; // should be loop closure?
        a ~= { /*printf("j = %d\n", j); */return j; };
    }

    int j = 19;
    foreach (f; a)
    {
        assert(f() == j);
        j += 10;
    }
}

void test5()
{
    int x = 3;  // x will be a closure variable

    int delegate()[] a;
    foreach (i; 1 .. 10)    // i will be a loop-closed variable
    {
        a ~= { /*printf("%d\n", i * x); */return i * x; };
    }

    int ix = 3;
    foreach (f; a)
    {
        assert(f() == ix);
        ix += 3;
    }

    x = 6;

    ix = 6;
    foreach (f; a)
    {
        assert(f() == ix);
        ix += 6;
    }
}

int main()
{
    test1();
    test2();
    test3();
    test4();
    test4x();
    test5();

    return 0;
}
