//

module test313;

import imports.test313a;

class C
{
    import imports.test313b;

    void test()
    {
        imports.test313b.bar();
        imports.test313a.foo();    // should pass
    }
}

int global;

void main()
{
    imports.test313a.foo();
    static assert(!__traits(compiles, imports.test313b.bar()));

    test313.C c;
    auto y1 = test313.global;

    {
        int imports;
        static assert(!__traits(compiles, imports.test313a.foo()));     // NG
    }

    .imports.test313a.foo();        // OK
    static assert(!__traits(compiles, { auto y = .test.global; }));     // NG

    C.imports.test313b.bar();
}

struct S
{
    import std.system;    // for Endian enumeration
    import std.c.windows.windows;

    class Stream
    {
        import std.c.stdlib;
    }

    class EndianStream : Stream
    {
        this(Endian end = std.system.endian) {}
    }
}
