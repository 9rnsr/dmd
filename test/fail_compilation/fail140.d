/*
TEST_OUTPUT:
---
fail_compilation/fail140.d(13): Error: escaping reference to local str
fail_compilation/fail140.d(19): Error: escaping reference to local str
fail_compilation/fail140.d(25): Error: escaping reference to local str
---
*/

char[] foo1()
{
    char[4] str = "abcd";
    return str;
}

char[] foo2()
{
    char[4] str = "abcd";
    return str[];
}

char[] foo2()
{
    char[4] str = "abcd";
    return cast(char[])str;
}
