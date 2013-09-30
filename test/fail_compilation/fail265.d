/*
TEST_OUTPUT:
---
fail_compilation/fail265.d(10): Error: found 'EOF' instead of statement
---
*/

void main()
{
    mixin(`for(;;)`);
}
