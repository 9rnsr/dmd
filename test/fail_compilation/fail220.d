/*
TEST_OUTPUT:
---
fail_compilation/fail220.d(14): Error: identifier expected for template value parameter
fail_compilation/fail220.d(14): Error: found '==' when expecting ')'
fail_compilation/fail220.d(14): Error: found 'class' when expecting ')'
fail_compilation/fail220.d(14): Error: Declaration expected, not ')'
fail_compilation/fail220.d(19): Error: unrecognized declaration
---
*/

template types(T)
{
    static if (is (T V : V[K], K == class))
    {
        static assert(false, "assoc");
    }
    static const int types = 4;
}

int i = types!(int);
