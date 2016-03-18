// REQUIRED_ARGS: -o-

/********************************************************/
/*
TEST_OUTPUT:
---
fail_compilation/fail_rightthis.d(25): Error: need 'this' for 'a' of type 'int'
fail_compilation/fail_rightthis.d(30): Error: template instance fail_rightthis.fooXXXXX!(a) error instantiating
---
*/

auto makeSXXXXX()
{
    int a;
    struct S
    {
        alias avar = a;

        int getA() { return a; }
    }
    // S is made nested struct in makeS()
    return S();
}

void fooXXXXX(alias a)() { a = 1; }

void testXXXXX()
{
    auto s = makeSXXXXX();
    fooXXXXX!(typeof(s).avar)(); // needs to be compile-time error
}

/********************************************************/
/*
TEST_OUTPUT:
---
fail_compilation/fail_rightthis.d(46): Error: field s must be initialized in constructor, because it is nested struct
fail_compilation/fail_rightthis.d(47): Error: field s must be initialized in constructor, because it is nested struct
---
*/

struct S3(alias a) { auto foo() { return a * 3; } }

void testX3()
{
    static class C3a { int v; S3!v s; this(long) {} }
    static class C3b { int v; S3!v s; /* no ctor */ }
}

/********************************************************/
/*
TEST_OUTPUT:
---
fail_compilation/fail_rightthis.d(64): Error: field s must be initialized in constructor, because it is nested struct
fail_compilation/fail_rightthis.d(66): Error: cannot access frame pointer of fail_rightthis.SX4.STX4!(v).STX4
fail_compilation/fail_rightthis.d(67): Error: cannot access frame pointer of fail_rightthis.SX4.STX4!(v).STX4
---
*/

struct STX4(alias a) { auto foo() { return a * 3; } }

void testX4()
{
    static struct SX4a { int v; STX4!v s; this(long) {} }
    static struct SX4b { int v; STX4!v s; /* no ctor */ }
    auto s1 = SX4b();
    auto s2 = SX4b(2);
}
