/*
TEST_OUTPUT:
---
fail_compilation/fail14965.d(11): Error: forward reference to inferred return type of function 'foo1'
fail_compilation/fail14965.d(12): Error: forward reference to inferred return type of function 'foo2'
fail_compilation/fail14965.d(16): Error: forward reference to inferred return type of function 'foo1'
fail_compilation/fail14965.d(17): Error: forward reference to inferred return type of function 'foo2'
---
*/

auto foo1() { alias F = typeof(foo1); }
auto foo2() { alias FP = typeof(&foo2); }

class C
{
    auto foo1() { alias F = typeof(this.foo1); }
    auto foo2() { alias FP = typeof(&this.foo2); }
}
