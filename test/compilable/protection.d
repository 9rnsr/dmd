

/******************************************/

private
{
    class localC {}
    struct localS {}
    union localU {}
    interface localI {}
    enum localE { foo }
    void localF() {}
    mixin template localMT() {}

    class localTC(T) {}
    struct localTS(T) {}
    union localTU(T) {}
    interface localTI(T) {}
    void localTF(T)() {}
}

void test1()
{
    import imports.prot1;

    // Private non-template declarations
    static assert(!__traits(compiles, privF()));
    static assert(!__traits(compiles, privC));
    static assert(!__traits(compiles, privS));
    static assert(!__traits(compiles, privU));
    static assert(!__traits(compiles, privI));
    static assert(!__traits(compiles, privE));
    static assert(!__traits(compiles, privMT));

    // Private local non-template declarations.
    static assert( __traits(compiles, localF()));
    static assert( __traits(compiles, localC));
    static assert( __traits(compiles, localS));
    static assert( __traits(compiles, localU));
    static assert( __traits(compiles, localI));
    static assert( __traits(compiles, localE));
    static assert( __traits(compiles, localMT));

    // Private template declarations.
    static assert(!__traits(compiles, privTC!int));
    static assert(!__traits(compiles, privTS!int));
    static assert(!__traits(compiles, privTU!int));
    static assert(!__traits(compiles, privTI!int));
    static assert(!__traits(compiles, privTF!int()));

    // Private local template declarations.
    static assert( __traits(compiles, localTC!int));
    static assert( __traits(compiles, localTS!int));
    static assert( __traits(compiles, localTU!int));
    static assert( __traits(compiles, localTI!int));
    static assert( __traits(compiles, localTF!int()));

    // Public template function with private type parameters.
    static assert(!__traits(compiles, publF!privC()));
    static assert(!__traits(compiles, publF!privS()));
    static assert(!__traits(compiles, publF!privU()));
    static assert(!__traits(compiles, publF!privI()));
    static assert(!__traits(compiles, publF!privE()));

    // Public template function with private alias parameters.
    static assert(!__traits(compiles, publFA!privC()));
    static assert(!__traits(compiles, publFA!privS()));
    static assert(!__traits(compiles, publFA!privU()));
    static assert(!__traits(compiles, publFA!privI()));
    static assert(!__traits(compiles, publFA!privE()));

    // Private alias.
    static assert(!__traits(compiles, privA));

    // Public template mixin.
    static assert(__traits(compiles, publMT));
}

/******************************************/

void test2()
{
    {
        import imports.prot2a, imports.prot2a;
        assert(foo() == 1);
        assert(bar(1) == 1);
        assert(Bar!int == 1);
        assert(var == 1);
        assert(S().var == 1);
    }
    {
        import imports.prot2a, imports.prot2b;
        assert(foo() == 1);
        assert(bar(1) == 1);
        assert(Bar!int == 1);
        assert(var == 1);
        assert(S().var == 1);
    }
    {
        import imports.prot2b, imports.prot2a;
        assert(foo() == 1);
        assert(bar(1) == 1);
        assert(Bar!int == 1);
        assert(var == 1);
        assert(S().var == 1);
    }
    {
        import imports.prot2a, imports.prot2c;
        assert(foo() == 1);
        assert(bar(1) == 1);
        assert(Bar!int == 1);
        assert(var == 1);
        assert(S().var == 1);
    }
    {
        import imports.prot2c, imports.prot2a;
        assert(foo() == 1);
        assert(bar(1) == 1);
        assert(Bar!int == 1);
        assert(var == 1);
        assert(S().var == 1);
    }
    {
        import imports.prot2a, imports.prot2d;
        static assert(!__traits(compiles, foo() == 1));
        static assert(!__traits(compiles, Bar!int == 1));
        static assert(!__traits(compiles, bar(1) == 1));
        static assert(!__traits(compiles, var == 1));
        static assert(!__traits(compiles, S().var == 1));
    }
    {
        import imports.prot2d, imports.prot2a;
        static assert(!__traits(compiles, foo() == 1));
        static assert(!__traits(compiles, Bar!int == 1));
        static assert(!__traits(compiles, bar(1) == 1));
        static assert(!__traits(compiles, var == 1));
        static assert(!__traits(compiles, S().var == 1));
    }
}
