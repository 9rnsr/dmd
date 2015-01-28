module imports.a13229;

int[2] x;
void fun(int i)
{
    x[i]++;
}

template Mix1324()  // from Bugzilla 1324
{
    int[1] arr;

    void test1324(int i)
    {
        try
        {
            arr[i] = i;
            assert(0);
        }
        catch (Error e)
        {
            assert(e.file[$-8..$] == "a13229.d");
            assert(e.line == 17);
        }
    }
}
