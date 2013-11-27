/*
TEST_OUTPUT:
---
fail_compilation/fail8150.d(12): Error: object.Exception is thrown but not caught
fail_compilation/fail8150.d(10): Error: constructor 'fail8150.Foo.this' is nothrow yet may throw
---
*/
struct Foo
{
    this(int) nothrow
    {
        throw new Exception("something");
    }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail8150.d(28): Error: object.Exception is thrown but not caught
fail_compilation/fail8150.d(26): Error: constructor 'fail8150.Bar.__ctor!().this' is nothrow yet may throw
fail_compilation/fail8150.d(35): Error: template instance fail8150.Bar.__ctor!() error instantiating
---
*/
struct Bar
{
    this()(int) nothrow
    {
        throw new Exception("something");
    }
}

void main()
{
    Foo(1);
    Bar(1);
}
