// REQUIRED_ARGS:
/*
TEST_OUTPUT:
---
fail_compilation/bug5.d(8): Error: function bug5.test1 no return exp; or assert(0); at end of function
---
*/
int test1()
{
    if (false)
        return 0;
}

/*
TEST_OUTPUT:
---
fail_compilation/bug5.d(20): Error: function bug5.test2 has no return statement, but is expected to return a value of type int
---
*/
int test2()
{
}
