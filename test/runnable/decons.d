extern(C) int printf(const char*, ...);

template Seq(T...) { alias Seq = T; }

void test1()
{
    {
        auto {x} = Seq!(1);
        assert(x == 1);
    }
    {
        auto {int x} = Seq!(1);
        assert(x == 1);
    }
    {
        auto {int x, ...} = Seq!(1, "a", []);
        assert(x == 1);
    }
    {
        auto {int x, r...} = Seq!(1, "a", []);
        assert(x == 1);
        assert(r == Seq!("a", []));
    }
//  auto {...} = 1;
//  auto {r...} = 1;
//  auto {{...}} = 1;   //?
//  //auto {{}} = 1;  //NG?
//  auto [x, {int a, b}] = 1;
//
//  {auto x} = 1;
//  {int[] x, r...} = 1;
//  {const int[] x} = 1;
//
//  [x] = 1;
}

void test2()
{
    int[] a1 = [1];
    int[] a3 = [1, 2, 3];
    {
        auto [int x] = a1;
        assert(x == 1);
    }
    {
        bool c = false;
        try             { auto [int y, z] = a1; }   // assertion failure
        catch (Error e) { c = true; }
        assert(c);
    }
    {
        auto [int x, ...] = a3;
        assert(x == 1);
    }
    {
        auto [int x, r...] = a3;
        assert(x == 1);
        assert(r == [2, 3]);
    }
//  auto [int x, int[] r...] = 1;
//  auto [...] = 1;
//  auto [r...] = 1;
//  [const int[] x] = 1;
//  [const int[] x] = 1;
//  [immutable int[] x, immutable(int[]) r...] = 1;
}

int main()
{
    test1();
    test2();

    printf("Success\n");
    return 0;
}
