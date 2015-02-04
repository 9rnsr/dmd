// REQUIRED_ARGS: -property
/*
TEST_OUTPUT:
---
fail_compilation/diag9241.d(18): Error: not a property s.splitLines
---
*/


S[] splitLines(S)(S s)
{
    return null;
}

void main()
{
    string s;
    s = s.splitLines;
}
