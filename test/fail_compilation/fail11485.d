/*
REQUIRED_ARGS: -o-
PERMUTE_ARGS:
TEST_OUTPUT:
---
fail_compilation/fail11485.d(16): Error: cannot cast i of type int to Object
fail_compilation/fail11485.d(17): Error: cannot cast i of type int to I
---
*/

interface I {}

void main()
{
    int i;
    cast(void)cast(Object)i;
    cast(void)cast(I)i;
}
