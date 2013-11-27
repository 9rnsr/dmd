/*
TEST_OUTPUT:
---
fail_compilation/fail283.d(13): Error: pure nested function 'do_sqr' cannot access mutable data 'y'
fail_compilation/fail283.d(13): Error: pure nested function 'do_sqr' cannot access mutable data 'y'
fail_compilation/fail283.d(13): Error: pure nested function 'do_sqr' cannot access mutable data 'y'
---
*/

pure int double_sqr(int x)
{
    int y = x;
    void do_sqr() pure { y *= y; }
    do_sqr();
    return y;
}

void main(string[] args)
{
    assert(double_sqr(10) == 100);
}
