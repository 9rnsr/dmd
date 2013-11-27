/*
TEST_OUTPUT:
---
fail_compilation/fail47.d(11): Error: variable fail47._foo is aliased to a function
fail_compilation/fail47.d(11): Error: variable fail47._foo is aliased to a function
fail_compilation/fail47.d(16): Error: foo is not an lvalue
---
*/

void foo() {}
int _foo;
alias _foo foo;

void main()
{
    foo = 1;
}

