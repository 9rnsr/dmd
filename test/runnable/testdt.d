// PERMUTE_ARGS:

static int bigarray[100][100];

void test1()
{
    for (int i = 0; i < 100; i += 1)
    {
        for (int j = 0; j < 100; j += 1)
        {
            //printf("Array %i %i\n", i, j);
            bigarray[i][j] = 0;
        }
    }
}

/***************************************************/
// 9425

struct S9425 { int array[4]; }

void test9425()
{
    int[4] array = 67;              // array = [67, 67, 67, 67]
    foreach (i; 0 .. array.length)
    assert(array[i] == 67);

    static S9425 s1 = S9425(67);    // s1.array = [67, 0, 0, 0]
    assert(array == s1.array);

    static S9425 s2 = { 67 };       // s2.array = [67, 0, 0, 0]
    assert(array == s2.array);
}

/***************************************************/

int main()
{
    test1();
    test9425();

    return 0;
}
