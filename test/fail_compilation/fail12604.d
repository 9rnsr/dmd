void main()
{
      int[1] a1 = [1,2,3];
    short[1] a2 = [1,2,3];

      int[1] b1; b1 = [1,2,3];
    short[1] b2; b2 = [1,2,3];

    short[1] c = [65536];
    short[1] d = [65536,2,3];
}

void test12606a()   // AssignExp::semantic
{
      uint[2] a1 = [1, 2, 3][];
    ushort[2] a2 = [1, 2, 3][];
      uint[2] a3 = [1, 2, 3][0 .. 3];
    ushort[2] a4 = [1, 2, 3][0 .. 3];
    a1 = [1, 2, 3][];
    a2 = [1, 2, 3][];
    a3 = [1, 2, 3][0 .. 3];
    a4 = [1, 2, 3][0 .. 3];
}

void test12606b()   // ExpInitializer::semantic
{
    static   uint[2] a1 = [1, 2, 3][];
    static   uint[2] a2 = [1, 2, 3][0 .. 3];
    static ushort[2] a3 = [1, 2, 3][];
    static ushort[2] a4 = [1, 2, 3][0 .. 3];
}

void testc()
{
    int[4] sa1;
    int[3] sa2;
    sa1[0..4] = [1,2,3];
    sa1[0..4] = sa2;
}
