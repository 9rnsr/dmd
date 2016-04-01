/*
TEST_OUTPUT:
---
fail_compilation/fail120.d(12): Error: 'this' is only defined in non-static member functions, not __lambda4
fail_compilation/fail120.d(13): Error: 'this' is only defined in non-static member functions, not __lambda5
---
*/

class Foo
{
    int[2] nodes;
    auto left = (){ return nodes[0]; };
    auto right = (){ return nodes[1]; };
}
