extern(C) int printf(const char*, ...);

template Seq(T...) { alias Seq = T; }

void test1()
{
    {   auto {x} = Seq!(1);
        assert(x == 1);
    }
    {   auto {int x} = Seq!(1);
        assert(x == 1);
    }
//  auto [int x] = [1];
//  auto [int x, ...] = 1;
//  auto [int x, r...] = 1;
//  auto [int x, int[] r...] = 1;
//  auto [...] = 1;
//  auto [r...] = 1;
//  auto {int x, ...} = 1;
//  auto {int x, r...} = 1;
//  auto {...} = 1;
//  auto {r...} = 1;
//  auto {{...}} = 1;   //?
//  //auto {{}} = 1;  //NG?
//  auto [x, {int a, b}] = 1;
//
//  {auto x} = 1;
//  {int[] x, r...} = 1;
//  {const int[] x} = 1;
//  [const int[] x] = 1;
//  [const int[] x] = 1;
//  [immutable int[] x, immutable(int[]) r...] = 1;
//
//  [x] = 1;
}

int main()
{
	test1();

    printf("Success\n");
    return 0;
}
