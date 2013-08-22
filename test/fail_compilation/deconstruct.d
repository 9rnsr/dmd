void main()
{
/*
TEST_OUTPUT:
---
fail_compilation/deconstruct.d(12): Error: cannot decompose expression (1) type int with tuple pattern 'auto {{}}'
fail_compilation/deconstruct.d(13): Error: cannot decompose expression (1) type int with tuple pattern 'auto {...}'
fail_compilation/deconstruct.d(14): Error: cannot decompose expression (1) type int with tuple pattern 'auto {r...}'
fail_compilation/deconstruct.d(15): Error: cannot decompose expression (1) type int with tuple pattern 'auto {{...}}'
---
*/
    auto {{}} = 1;  //NG?
    auto {...} = 1;
    auto {r...} = 1;
    auto {{...}} = 1;   //?

/*
TEST_OUTPUT:
---
fail_compilation/deconstruct.d(25): Error: cannot decompose expression (1) type int with tuple pattern '{auto x}'
fail_compilation/deconstruct.d(26): Error: cannot decompose expression (1) type int with tuple pattern '{int[] x, r...}'
fail_compilation/deconstruct.d(27): Error: cannot decompose expression (1) type int with tuple pattern '{const int[] x}'
---
*/
    {auto x} = 1;
    {int[] x, r...} = 1;
    {const int[] x} = 1;

/*
TEST_OUTPUT:
---
fail_compilation/deconstruct.d(38): Error: cannot decompose expression (1) type int with array pattern 'auto [x, {int a, b}]'
fail_compilation/deconstruct.d(39): Error: cannot decompose expression (1) type int with array pattern 'auto [int x, int[] r...]'
fail_compilation/deconstruct.d(40): Error: cannot decompose expression (1) type int with array pattern 'auto [...]'
fail_compilation/deconstruct.d(41): Error: cannot decompose expression (1) type int with array pattern 'auto [r...]'
---
*/
    auto [x, {int a, b}] = 1;
    auto [int x, int[] r...] = 1;
    auto [...] = 1;
    auto [r...] = 1;

/*
TEST_OUTPUT:
---
fail_compilation/deconstruct.d(51): Error: cannot decompose expression (1) type int with array pattern '[const int[] x]'
fail_compilation/deconstruct.d(52): Error: cannot decompose expression (1) type int with array pattern '[const int[] x]'
fail_compilation/deconstruct.d(53): Error: cannot decompose expression (1) type int with array pattern '[immutable int[] x, immutable(int[]) r...]'
---
*/
    [const int[] x] = 1;
    [const int[] x] = 1;
    [immutable int[] x, immutable(int[]) r...] = 1;
}
