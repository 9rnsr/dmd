/*
TEST_OUTPUT:
---
fail_compilation/fail11382.d(15): Error: variable fail11382.foo.s has scoped destruction, cannot build closure
---
*/

struct S
{
    ~this() {}
}

auto foo()
{
    S s = S();
    return { s = S(); };
}
