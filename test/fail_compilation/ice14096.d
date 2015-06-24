/*
TEST_OUTPUT:
---
fail_compilation/ice14096.d(29): Error: cannot access frame pointer of ice14096.main.Baz!((i) => x).Baz
fail_compilation/ice14096.d(23): Error: template instance ice14096.foo!(Tuple!(Baz!((i) => x))).foo.bar!(t) error instantiating
fail_compilation/ice14096.d(41):        instantiated from here: foo!(Tuple!(Baz!((i) => x)))
---
*/

struct Tuple(Types...)
{
    Types expand;
    alias expand this;
    alias field = expand;
}
Tuple!T tuple(T...)(T args)
{
    return typeof(return)(args);
}

auto foo(T)(T t)
{
    bar!t();
}

auto bar(alias s)()
{
    // default construction is not possible for: Tuple!(Baz!(i => x))
    typeof(s) p;
}

struct Baz(alias f)
{
    void g() { f(1); }
}

void main()
{
    int x;
    auto t = tuple(Baz!(i => x)());
    foo(t);
}
