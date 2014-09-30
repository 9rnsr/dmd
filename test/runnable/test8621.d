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

int main()
{
    test1();
    test2();

    return 0;
}
