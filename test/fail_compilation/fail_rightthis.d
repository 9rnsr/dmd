// REQUIRED_ARGS: -o-
/*
TEST_OUTPUT:
---
fail_compilation/fail_rightthis.d(23): Error: need 'this' for 'a' of type 'int'
fail_compilation/fail_rightthis.d(28): Error: template instance fail_rightthis.fooXXXXX!(a) error instantiating
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
