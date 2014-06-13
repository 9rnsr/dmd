/*
TEST_OUTPUT:
---
fail_compilation/fail50.d(11): Error: variable a cannot be read at compile time
---
*/

struct Marko
{
    int a;
    int* m = &a;
}
