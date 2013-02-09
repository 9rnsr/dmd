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
// 2931

struct Bug2931
{
    int val[3][4];
}

struct Outer2931
{
    Bug2931 p = Bug2931(67);  // Applies to struct static initializers too
    int zoom = 2;
    int move = 3;
    int scale = 4;
}

int bug2931a()
{
    Outer2931 v;
    assert(v.move == 3);
    assert(v.scale == 4);
    return v.zoom;
}

int bug2931b()
{
    Outer2931 v;
    assert(v.move == 3);
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            //printf("[%d][%d] = %d\n", j, i, v.p.val[j][i]);
            assert(v.p.val[j][i] == 67);
        }
    }
    //printf("v.zoom = %d\n", v.zoom);
    assert(v.scale == 4);
    return v.zoom;
}

static assert(bug2931a() == 2);
//static assert(bug2931b() == 2);

void test2931()
{
    assert(bug2931a() == 2);
    assert(bug2931b() == 2);
}

/***************************************************/
// 9425

struct S9425 { int[4] array; }

void test9425()
{
    int[4] array = 67;              // array = [67, 67, 67, 67]
    foreach (i; 0 .. array.length)
    assert(array[i] == 67);

    static S9425 s1 = S9425(67);    // s1.array = [67, 0, 0, 0]
    assert(array == s1.array);

    static S9425 s2 = { 67 };       // s2.array = [67, 0, 0, 0]
    assert(array == s2.array);

    int[2][3] lsa = 67;
    static int[2][3] gsa = 67;
    assert(lsa == gsa);
    foreach (i; 0 .. lsa.length)
    {
        foreach (j; 0 .. lsa[0].length)
        {
            assert(lsa[i][j] == 67);
            assert(gsa[i][j] == 67);
        }
    }
}

/***************************************************/

int main()
{
    test1();
    test2931();
    test9425();

    return 0;
}
