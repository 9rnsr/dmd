// PERMUTE_ARGS: -d -dw
/*
TEST_OUTPUT:
---
fail_compilation/fail121.d(25): Error: .typeinfo deprecated, use typeid(type)
fail_compilation/fail121.d(25): Error: .typeinfo deprecated, use typeid(type)
fail_compilation/fail121.d(25): Error: list[1].typeinfo is not an lvalue
---
*/

// segfault on DMD0.150, never failed if use typeid() instead.

struct myobject
{
    TypeInfo objecttype;
    void* offset;
}

myobject[] list;

void foo()
{
    int i;

    list[1].typeinfo = i.typeinfo;
}
