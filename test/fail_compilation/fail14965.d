/*
TEST_OUTPUT:
---
fail_compilation/fail14965.d(15): Error: forward reference to inferred return type of function 'foo1'
fail_compilation/fail14965.d(16): Error: forward reference to inferred return type of function 'foo2'
fail_compilation/fail14965.d(18): Error: forward reference to inferred return type of function 'bar'
fail_compilation/fail14965.d(19): Error: forward reference to inferred return type of function 'baz'
fail_compilation/fail14965.d(23): Error: forward reference to inferred return type of function 'foo1'
fail_compilation/fail14965.d(24): Error: forward reference to inferred return type of function 'foo2'
fail_compilation/fail14965.d(26): Error: forward reference to inferred return type of function 'bar'
fail_compilation/fail14965.d(27): Error: forward reference to inferred return type of function 'baz'
---
*/

auto foo1() { alias F = typeof(foo1); }
auto foo2() { alias FP = typeof(&foo2); }

auto bar() { auto fp = &bar; }
auto baz() { auto fp = cast(void function())&baz; }

class C
{
    auto foo1() { alias F = typeof(this.foo1); }
    auto foo2() { alias FP = typeof(&this.foo2); }

    auto bar() { auto fp = &this.bar; }
    auto baz() { auto dg = cast(void delegate())&this.baz; }
}
