
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