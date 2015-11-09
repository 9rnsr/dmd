/*
TEST_OUTPUT:
---
fail_compilation/diag10169.d(11): Error: variable imports.a10169.B.x is not accessible from module diag10169
---
*/
import imports.a10169;

void main()
{
    auto a = B.init.x;
}
