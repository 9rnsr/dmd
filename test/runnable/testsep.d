// COMPILE_SEPARATELY
// EXTRA_SOURCES: imports/sepmod1.d imports/sepmod2.d

import imports.sepmod;

//extern(C) int printf(const char*, ...);

void main()
{
    assert(imports.sepmod.foo() == 1);
    assert(imports.sepmod.bar() == 2);

    assert(new Foo().run() == 1);
    assert(new Bar().run() == 2);

    Object o;
    o = Object.factory("imports.sepmod.Foo");
    assert(o);
    Foo foo = cast(Foo)o;
    assert(foo);
    assert(foo.run() == 1);

    o = Object.factory("imports.sepmod.Bar");
    assert(o);
    Bar bar = cast(Bar)o;
    assert(bar);
    assert(bar.run() == 2);
}
