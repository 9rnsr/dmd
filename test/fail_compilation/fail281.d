/*
TEST_OUTPUT:
---
fail_compilation/fail281.d(24): Error: template instance fail281.foo!4294967295u recursive expansion
---
*/

// Issue 2920 - recursive templates blow compiler stack
// template_29_B.

template foo(size_t i)
{
    static if (i > 0)
    {
        const size_t bar = foo!(i - 1).bar;
    }
    else
    {
        const size_t bar = 1;
    }
}
int main()
{
    return foo!(size_t.max).bar;
}
