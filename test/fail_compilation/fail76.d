/*
TEST_OUTPUT:
---
fail_compilation/fail76.d(9): Error: alias fail76.a conflicts with function D main at fail_compilation/fail76.d(11)
---
*/

alias main a;
alias void a;

void main()
{
    a;
}
