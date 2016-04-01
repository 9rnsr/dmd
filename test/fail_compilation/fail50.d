/*
TEST_OUTPUT:
---
fail_compilation/fail50.d(11): Error: 'this' is only defined in non-static member functions, not Marko
---
*/

struct Marko
{
    int a;
    int* m = &a;
}
