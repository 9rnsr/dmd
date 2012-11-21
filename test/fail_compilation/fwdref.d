
struct S
{
    union {
        S s = S();
    }
}

struct A
{
    immutable A fa = A();
}

struct B
{
    B fa = B(0);

    this(uint x) {}
}
pragma(msg, B.sizeof);

struct C
{
    immutable C fa = C();
    // -> Error: variable test.Foo7974.fa forward reference in type inference from Foo7974(0)
}

struct D
{
    immutable fa = D();
    // -> Error: variable test.Foo7974.fa forward reference in type inference from Foo7974(0)
    // -> Error: struct test.Foo7974 no size yet for forward reference
}
