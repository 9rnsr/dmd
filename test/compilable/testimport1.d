// PERMUTE_ARGS:

module testimport1;

import imports.testimport1a;

class C
{
    import imports.testimport1b;

    void test()
    {
        imports.testimport1b.bar();
        imports.testimport1a.foo();
    }
}

int global;

void main()
{
    // From here, 1a is visible but 1b isn't.
    imports.testimport1a.foo();
    static assert(!__traits(compiles, imports.testimport1b.bar()));

    testimport1.C c;
    auto y1 = testimport1.global;

    // A declaration always hide same name root of package hierarchy.
    {
        int imports;
        static assert(!__traits(compiles, imports.testimport1a.foo()));
    }

    // FQN access with Module Scope Operator works
    .imports.testimport1a.foo();
    auto y2 = .testimport1.global;

    // FQN access through class is not allowed
    static assert(!__traits(compiles, { C.imports.testimport1b.bar(); }));
}
