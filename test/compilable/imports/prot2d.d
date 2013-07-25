module imports.prot2d;
public
{
    int foo() { return 1; }
    int bar(T)(T) { return 1; }
    template Bar(T) { enum Bar = 2; }
    int var = 1;
    struct S { int var = 1; }
}
