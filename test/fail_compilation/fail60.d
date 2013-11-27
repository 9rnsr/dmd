/*
TEST_OUTPUT:
---
fail_compilation/fail60.d(15): Error: 'this' is only defined in non-static member functions, not A
fail_compilation/fail60.d(15): Error: 'this' for nested class must be a class type, not _error_
---
*/

class A
{
    class B
    {
    }

    B b = new B;
}
