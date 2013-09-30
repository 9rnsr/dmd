/*
TEST_OUTPUT:
---
fail_compilation/fail225.d(19): Error: cannot implicitly convert expression (1) of type int to immutable(char*)
fail_compilation/fail225.d(19): Error: too many initializers for Struct
fail_compilation/fail225.d(22): Error: cannot implicitly convert expression (iStruct2) of type immutable(Struct) to Struct
fail_compilation/fail225.d(24): Error: cannot implicitly convert expression (& ch) of type char* to immutable(char*)
---
*/

struct Struct
{
    char* chptr;
}

void main()
{
    char ch = 'd';
    immutable Struct iStruct1 = {1, &ch};

    immutable Struct iStruct2;
    Struct y = iStruct2;

    immutable Struct iStruct3 = {&ch};
}
