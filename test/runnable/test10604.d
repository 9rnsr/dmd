import a, b;
void main()
{
    //Test.counter = 5;
    //foo();
    auto n = Foo!1L;

    // better-matched private function is implicitly removed from overload set candidates
    {
        assert(bar(1) == 2);
        assert(bar(1L) == 2);

        assert(baz(1) == 2);
        assert(baz(1L) == 2);

        auto t = new Test;
        assert(t.baz(1) == 2);
        assert(t.baz(1L) == 2);
    }

    // Issue 10604 - Not consistent access check for overloaded symbols
    {
        static assert(!__traits(compiles, { auto x1 = Voo1!int; }));
        static assert(!__traits(compiles, { auto x1 = Voo2!int; }));
        assert(Voo1!100 == 2);
        assert(Voo2!100 == 2);

        static assert(!__traits(compiles, voo1(100)));
        static assert(!__traits(compiles, voo2(100)));
        assert(voo1("a") == 2);
        assert(voo2("a") == 2);
    }

    //static assert(!__traits(compiles, PrivFoo));
    //static assert(!__traits(compiles, { alias X = PrivFoo; }));
}
