// PERMUTE_ARGS: -inline -g -O

void main()
{
    int[] arr = [1,2,3];

#line 100 "foo"
    try { auto n = arr[3];
          assert(0); }
    catch (Error e)
    {
        assert(e.file == "foo");  // fails
        assert(e.line == 100);
    }

#line 200 "bar"
    try { auto a = arr[3..9];
          assert(0); }
    catch (Error e)
    {
        assert(e.file == "bar");  // fails
        assert(e.line == 200);
    }
}
