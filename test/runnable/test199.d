// PERMUTE_ARGS:

/******************************************/

void test199a()
{
    {
        uint foo;
    } end_first_block:

    {
        uint foo;
    } end_second_block:

    {
        uint foo;   // Error: declaration main.main.foo is already defined
                    // --> succeed to compile
    } end_third_block:

    return;
}

/******************************************/

int i199b = 3;

void test199b()
{
    {
        int some_condition = 1;
        if (some_condition)
            goto block_end;

        /* dummy code */
    } block_end:

    {
        int i199b = 7;
        assert(i199b == 7); // local i199b
    }

    //assert(i199b == 3); // global i199b
    static assert(!__traits(compiles, i199b == 3));
    assert(.i199b == 3); // global i199b
}

/******************************************/

class C199
{
    int i199c = 3;

    void test()
    {
        {
            int some_condition = 1;
            if (some_condition)
                goto block_end;

            /* dummy code */
        } block_end:

        {
            int i199c = 7;
            assert(i199c == 7); // local i199c
        }

        //assert(i199c == 3); // field i199c
        static assert(!__traits(compiles, i199c == 3));
        assert(this.i199c == 3); // field i199c
    }
}

void test199c()
{
    new C199().test();
}

/******************************************/

void main()
{
    test199a();
    test199b();
    test199c();
}
