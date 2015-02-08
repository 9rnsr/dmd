/*
TEST_OUTPUT:
---
fail_compilation/fail2789.d(15): Error: function fail2789.A2789.m () conflicts with at fail_compilation/fail2789.d(10)
fail_compilation/fail2789.d(25): Error: function fail2789.A2789.m () conflicts with at fail_compilation/fail2789.d(10)
---
*/
class A2789
{
    int m()
    {
        return 1;
    }

    float m()       // conflict
    {
        return 2.0;
    }

    float m() const // doen't conflict
    {
        return 3.0;
    }

    static void m() // conflict
    {
    }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail2789.d(46): Error: function fail2789.f3 () conflicts with at fail_compilation/fail2789.d(45)
fail_compilation/fail2789.d(49): Error: function fail2789.f4 () conflicts with at fail_compilation/fail2789.d(48)
fail_compilation/fail2789.d(52): Error: function fail2789.f5 () conflicts with at fail_compilation/fail2789.d(51)
fail_compilation/fail2789.d(55): Error: function fail2789.f6 () conflicts with at fail_compilation/fail2789.d(54)
---
*/
void f1();
void f1() {}    // ok

void f2() {}
void f2();      // ok

void f3();
void f3();      // ok

void f4() {}
void f4() {}    // conflict

void f5() @safe {}
void f5() @system {}    // conflict

auto f6() { return 10; }    // int()
auto f6() { return ""; }    // string(), conflict

/*
TEST_OUTPUT:
---
fail_compilation/fail2789.d(70): Error: function fail2789.mul14147 (const(int[]) left, const(int[]) right) conflicts with at fail_compilation/fail2789.d(66)
---
*/
struct S14147(alias func)
{
}
pure auto mul14147(const int[] left, const int[] right)
{
    S14147!(a => a) s;
}
pure auto mul14147(const int[] left, const int[] right)
{
    S14147!(a => a) s;
}
