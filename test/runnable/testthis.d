// runnable/traits.d    9091,8972,8971,7027
// runnable/test4.d     test6()


// test for DsymbolExp::semantic fix
void testwith()
{
    struct S { int a; }
    class C { int a; }
    static assert(!__traits(compiles, { with (S) { int n = a; } }));
    static assert(!__traits(compiles, { with (C) { int n = a; } }));
}

void main()
{
}