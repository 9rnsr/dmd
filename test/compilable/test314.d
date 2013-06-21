// REQUIRED_ARGS: -Icompilable/extra-files
// EXTRA_SOURCE: imports/test314a.d
// EXTRA_SOURCE: imports/test314b.d
// EXTRA_SOURCE: extra-files/test314x.d

import imports.test314a;

void main()
{
    static assert(!__traits(compiles, imports.test314b.bar()));
    static assert(!__traits(compiles, imports.test314a.imports.test314b.bar()));
    static assert(!__traits(compiles, .imports.test314a.foo()));
    baz();
    pragma(msg, test314x.mangleof);

    alias A = imports.test314a;
    A.foo();
    static assert(!__traits(compiles, A.bar()));
    A.baz();
}
