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
test_output:
---
fail_compilation/fail_rightthis.d(45): Error: field s must be initialized in constructor, because it is nested struct
fail_compilation/fail_rightthis.d(47): Error: field s must be initialized in constructor, because it is nested struct
---
*/
/+
struct S3(alias a) { auto foo() { return a * 3; } }

class C3a { int v; S3!v s; }            // NG

class C3b { int v; S3!v s; this() {} }  // OK
+/
