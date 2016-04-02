/*
TEST_OUTPUT:
---
fail_compilation/fail289.d(12): Error: cannot cast expression & fun of type void function() to void delegate()
---
*/

alias void delegate() Dg;
void fun() {}
void gun()
{
    Dg d = cast(void delegate())&fun;
}
