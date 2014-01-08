// REQUIRED_ARGS: -defaultlib= -betterC
/*
TEST_OUTPUT:
---
fail_compilation/fail11881.d(15): Error: cannot use typeid expression under the -betterC
fail_compilation/fail11881.d(17): Error: cannot use assert expression under the -betterC
fail_compilation/fail11881.d(19): Error: cannot use new expression under the -betterC
---
*/

struct S {}

extern(C) int main(int argc, char** argv)
{
    auto ti = typeid(S);

    assert(0, "error");

    auto pnum = new int();

    return 0;
}
