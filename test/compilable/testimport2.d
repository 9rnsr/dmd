// REQUIRED_ARGS: -Icompilable/extra-files
// PERMUTE_ARGS:
// EXTRA_SOURCE: imports/testimport2a.d
// EXTRA_SOURCE: imports/testimport2b.d
// EXTRA_SOURCE: imports/testimport2c.d

import imports.testimport2a;

void main()
{
    // public symbols which directly imported are visible
    foo();
    imports.testimport2a.foo(); // by FQN
    {
        alias A = imports.testimport2a;
        A.foo();
        static assert(!__traits(compiles, A.bar()));
        A.baz();
    }

    // public symbols through private import are invisible
    static assert(!__traits(compiles, bar()));
    static assert(!__traits(compiles, imports.testimport2b.bar()));
    // FQN of privately imported module is invisible
    static assert(!__traits(compiles, imports.testimport2b.stringof));
    {
        static assert(!__traits(compiles, { alias B = imports.testimport2b; }));
    }

    // public symbols which indirectly imported through public import are visible
    baz();
    imports.testimport2c.baz(); // by FQN
    // FQN of publicly imported module is visible
    static assert(imports.testimport2c.stringof == "module testimport2c");
    {
        alias C = imports.testimport2c;
        static assert(!__traits(compiles, C.foo()));
        static assert(!__traits(compiles, C.bar()));
        C.baz();
    }

    // Import Declaration itself should not have FQN
    static assert(!__traits(compiles, imports.testimport2a.imports.testimport2b.bar()));
    static assert(!__traits(compiles, imports.testimport2a.imports.testimport2c.baz()));

    // Applying Module Scope Operator to package/module FQN
    .imports.testimport2a.foo();
    static assert(!__traits(compiles, .imports.testimport2b.bar()));
    .imports.testimport2c.baz();
}
