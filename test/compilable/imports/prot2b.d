module imports.prot2b;
private
{
    int foo() { return 2; }
    int bar(T)(T) { return 2; }
    template Bar(T) { enum Bar = 2; }
    int var = 2;
    struct S { int var = 2; }
}
