/*
TEST_OUTPUT:
---
fail_compilation/fail95.d(19): Error: template fail95.A cannot deduce template function from argument types !()(int), Candidates are:
fail_compilation/fail95.d(11):        fail95.A(alias T)(T)
---
*/

// Issue 142 - Assertion failure: '0' on line 610 in file 'template.c'

template A(alias T)
{
    void A(T) { T = 2; }
}

void main()
{
    int i;
    A(i);
    assert(i == 2);
}

