// PERMUTE_ARGS: -inline
/*
TEST_OUTPUT:
---
fail_compilation/fail46.d(19): Error: 'this' is only defined in non-static member functions, not main
---
*/

struct MyStruct
{
    int bug()
    {
        return 3;
    }
}

int main()
{
    assert(MyStruct.bug() == 3);
    return 0;
}
