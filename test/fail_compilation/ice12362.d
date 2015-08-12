/*
TEST_OUTPUT:
---
fail_compilation/ice12362.d(12): Error: variable ice12362.main.bar cannot be declared with opaque type foo
fail_compilation/ice12362.d(12): Error: cannot interpret foo at compile time
---
*/
enum foo;

void main()
{
    enum bar = foo;
}
