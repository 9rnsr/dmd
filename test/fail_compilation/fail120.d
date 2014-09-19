/*
TEST_OUTPUT:
---
fail_compilation/fail120.d(12): Error: compile-time delegate literal cannot access outer variable 'nodes'
fail_compilation/fail120.d(13): Error: compile-time delegate literal cannot access outer variable 'nodes'
---
*/

class Foo
{
    int[2] nodes;
    auto left = (){ return nodes[0]; };
    auto right = (){ return nodes[1]; };
}
