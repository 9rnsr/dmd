module imports.prot2a;
public
{
    int foo() { return 1; }
    int bar(T)(T) { return 1; }
    template Bar(T) { enum Bar = 1; }
    int var = 1;
    struct S { int var = 1; }
}
