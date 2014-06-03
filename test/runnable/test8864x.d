// BUG? why this is compiled in DeclDefs scope!?
//int[2][] a4 = [1,2];

void main()
{
    struct S1(E) { E a; }

    // E <- E
    {
        // ExpInitializer

        int    n1 =  1;
        assert(n1 == 1);

        S1!int s1 = S1!int(1);
        assert(s1.a ==     1);
    }
    {
        // ArrayInitializer

        int[]  a1 =  [1];
        assert(a1 == [1]);

        int[2] a2 =  [1,2];
        assert(a2 == [1,2]);

        int[][] a3 =  [[1,2]];
        assert( a3 == [[1,2]]);

        int[2][] a4 =  [[1,2]];
        assert(  a4 == [[1,2]]);

        int[][2] a5 =  [[1],[2]];
        assert(  a5 == [[1],[2]]);

        int[2][2] a6 =  [[1,2],[3,4]];
        assert(   a6 == [[1,2],[3,4]]);

        int[][2][2] a7 =  [[[1],[2]],[[3],[4]]];
        assert(     a7 == [[[1],[2]],[[3],[4]]]);

        int[2][][2] a8 =  [[[1,2],[2,3]],[[3,4],[4,5]]];
        assert(     a8 == [[[1,2],[2,3]],[[3,4],[4,5]]]);

        int[2][2][] a9 =  [[[1,2],[3,4]]];
        assert(     a9 == [[[1,2],[3,4]]]);
    }
    {
        // ExpInitializer in StructInitializer
        alias SX = S1!int;

        S1!int s1   = {a:1};
        assert(s1.a ==   1);
    }
    {
        // ExpInitializer in StructInitializer in ArrayInitializer
        alias SX = S1!int;

        SX[]   s1 =  [{a:1}];
        assert(s1 == [SX(1)]);

        SX[2]  s2 =  [{a:1},{a:2}];
        assert(s2 == [SX(1),SX(2)]);

        SX[][] s3 =  [[{a:1},{a:2}]];
        assert(s3 == [[SX(1),SX(2)]]);

        SX[2][] s4 =  [[{a:1},{a:2}]];
        assert( s4 == [[SX(1),SX(2)]]);

        SX[][2] s5 =  [[{a:1}],[{a:2}]];
        assert( s5 == [[SX(1)],[SX(2)]]);

        SX[2][2] s6 =  [[{a:1},{a:2}],[{a:3},{a:4}]];
        assert(  s6 == [[SX(1),SX(2)],[SX(3),SX(4)]]);

        SX[][2][2] s7 =  [[[{a:1}],[{a:2}]],[[{a:3}],[{a:4}]]];
        assert(    s7 == [[[SX(1)],[SX(2)]],[[SX(3)],[SX(4)]]]);

        SX[2][][2] s8 =  [[[{a:1},{a:2}],[{a:2},{a:3}]],[[{a:3},{a:4}],[{a:4},{a:5}]]];
        assert(    s8 == [[[SX(1),SX(2)],[SX(2),SX(3)]],[[SX(3),SX(4)],[SX(4),SX(5)]]]);

        SX[2][2][] s9 =  [[[{a:1},{a:2}],[{a:3},{a:4}]]];
        assert(    s9 == [[[SX(1),SX(2)],[SX(3),SX(4)]]]);
    }
    {
        // ExpInitializer in ArrayInitializer in StructInitializer

        S1!(int[]) s1 = {a:[1]};
        assert(    s1.a == [1]);

        S1!(int[2]) s2 = {a:[1, 2]};
        assert(     s2.a == [1, 2]);

        S1!(int[][]) s3 = {a:[[1, 2]]};
        assert(      s3.a == [[1, 2]]);

        S1!(int[2][]) s4 = {a:[[1,2]]};
        assert(       s4.a == [[1,2]]);

        S1!(int[][2]) s5 = {a:[[1],[2]]};
        assert(       s5.a == [[1],[2]]);

        S1!(int[2][2]) s6 = {a:[[1,2],[3,4]]};
        assert(        s6.a == [[1,2],[3,4]]);

        S1!(int[][2][2]) s7 = {a:[[[1],[2]],[[3],[4]]]};
        assert(          s7.a == [[[1],[2]],[[3],[4]]]);

        S1!(int[2][][2]) s8 = {a:[[[1,2],[2,3]],[[3,4],[4,5]]]};
        assert(          s8.a == [[[1,2],[2,3]],[[3,4],[4,5]]]);

        S1!(int[2][2][]) s9 = {a:[[[1,2],[3,4]]]};
        assert(          s9.a == [[[1,2],[3,4]]]);
    }

    // E[x][y]... <- E
    {
        // ExpInitializer

        int[2] a1 = 1;      // int <- && [2]
        assert(a1 == [1,1]);

        int[2][2] a2 = 1;   // int <- && [2][2]
        assert(   a2 == [[1,1], [1,1]]);
    }
    {
        // ExpInitializer in ArrayInitializer

        int[][2] a1 =   [1,2];              // int[] <- && [2]
        assert(  a1 == [[1,2],[1,2]]);

      //int[2][2] a2 =   [1,2];             // int[2] <- && [2] (should work)
      //int[2][2] a2 = cast(int[2])([1,2]);            // ditto
      //assert(   a2 == [[1,2], [1,2]]);

        int[][][2] a3 =   [[1,2]];          // int[][] <- && [2]
        assert(    a3 == [[[1,2]], [[1,2]]]);

      //int[][2][2] a4 =   [[1,2],[3,4]];   // int[][2] <- && [2] (should work)
      //assert(     a4 == [[[1,2],[3,4]], [[1,2],[3,4]]]);

        int[2][][2] a5 =   [[1,2],[3,4]];   // int[2][] <- && [2]
        assert(     a5 == [[[1,2],[3,4]], [[1,2],[3,4]]]);

      //int[2][1][2] a6 =   [[1,2]];        // int[2][1] <- && [2] (should work)
      //int[2][1][2] a6x = cast(int[2][1])([[1,2]]);    // ditto
      //assert(      a6 == [[[1,2]], [[1,2]]]);


        int[][2][2] a7 =    [1,2];              // int[] <- && [2][2]
        assert(     a7 == [[[1,2],[1,2]], [[1,2],[1,2]]]);

      //int[2][2][2] a8 =   [1,2];              // int[2] <- && [2][2] (should work)
      //assert(      a8 == [[[1,2],[1,2]], [[1,2],[1,2]]]);

        int[][][2][2] a9 =    [[1,2]];          // int[][] <- && [2][2]
        assert(       a9 == [[[[1,2]], [[1,2]]], [[[1,2]], [[1,2]]]]);

      //int[][2][2][2] a10 =    [[1,2],[3,4]];  // int[][2] <- && [2][2] (should work)
      //assert(        a10 == [[[[1,2],[3,4]], [[1,2],[3,4]]], [[[1,2],[3,4]], [[1,2],[3,4]]]]);

        int[2][][2][2] a11 =    [[1,2],[3,4]];  // int[2][] <- && [2][2]
        assert(        a11 == [[[[1,2],[3,4]], [[1,2],[3,4]]], [[[1,2],[3,4]], [[1,2],[3,4]]]]);

      //int[2][1][2][2] a12 =    [[1,2]];       // int[2][1] <- && [2][2] (should work)
      //int[2][1][2][2] a12 = cast(int[2][1])([[1,2]]);    // ditto
      //assert(         a12 == [[[[1,2]], [[1,2]]], [[[1,2]], [[1,2]]]]);
    }
    {
        // ExpInitializer in StructInitializer
        alias SX = S1!int;

        SX[2] s1 = {a:1};   // S <- && [2]
        assert(s1 == [SX(1), SX(1)]);
    }
    {
        // ExpInitializer in StructInitializer in ArrayInitializer
        alias SX = S1!int;

      //SX[2][2] s4 =    {a:1};     // S <- && [2][2] (should work)
        SX[2][2] s4 =    SX(1);     // ditto
        assert(  s4 == [[SX(1), SX(1)], [SX(1), SX(1)]]);

      //SX[][2] s5 =   [{a:1}];     // S[] <- && [2] (should work)
        SX[][2] s5 =   [SX(1)];     // ditto
        assert( s5 == [[SX(1)], [SX(1)]]);
    }
}
