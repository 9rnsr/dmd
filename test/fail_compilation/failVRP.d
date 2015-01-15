/*
TEST_OUTPUT:
---
fail_compilation/failVRP.d(14): Error: index range [10, 10] cannot cover the array bounds 0..5
fail_compilation/failVRP.d(16): Error: index range [10, 14] cannot cover the array bounds 0..5
---
*/

void main()
{
    size_t n;
    int[5] b;

    auto x0 = b[10];    // changed error message...

    auto x1 = b[n%5 + 10];    // should be compile-time error?

    //const size_t i = n + 10;
    //auto x2 = b[i];
}
