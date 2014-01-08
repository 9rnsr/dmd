// REQUIRED_ARGS: -defaultlib= -betterC
/*
TEST_OUTPUT:
---
fail_compilation/fail11881.d(18): Error: variable fail11881.main.var cannot define closure variable under the -betterC
fail_compilation/fail11881.d(23): Error: cannot use typeid expression under the -betterC
fail_compilation/fail11881.d(24): Error: cannot use new expression under the -betterC
fail_compilation/fail11881.d(25): Error: cannot use array literal expression under the -betterC
fail_compilation/fail11881.d(29): Error: cannot use array concatenation under the -betterC
fail_compilation/fail11881.d(30): Error: cannot use array appending under the -betterC
---
*/

struct S {}

extern(C) int main(int argc, char** argv)
{
    int var;
    void foo() { var = 20; }
    static void delegate() dg;
    dg = &foo;

    auto ti = typeid(S);
    auto ptr = new int();
    int[] darr = [1,2,3];

    int[3] sarr = [1,2,3];    //OK
    int[] a = sarr[];
    a = a ~ 10;
    a ~= 20;

    return 0;
}
