/*
TEST_OUTPUT:
---
fail_compilation/fail289.d(12): Error: cannot cast from function pointer to delegate
---
*/

alias void delegate() dg;
void fun() {}
void gun()
{
    dg d = cast(void delegate())&fun;
}
