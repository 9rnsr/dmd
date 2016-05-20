void test_NoImplicitSignCast()
{
      byte sb;     ubyte ub;
     short ss;    ushort us;
       int sn;      uint un;
      long sl;     ulong ul;

    // 0. same-signed-ness
    assert(sb > sb);
    assert(sb > ss);
    assert(sb > sn);
    assert(sb > sl);
    assert(ss > sb);
    assert(ss > ss);
    assert(ss > sn);
    assert(ss > sl);
    assert(sn > sb);
    assert(sn > ss);
    assert(sn > sn);
    assert(sn > sl);
    assert(sl > sb);
    assert(sl > ss);
    assert(sl > sn);
    assert(sl > sl);

    assert(ub > ub);
    assert(ub > us);
    assert(ub > un);
    assert(ub > ul);
    assert(us > ub);
    assert(us > us);
    assert(us > un);
    assert(us > ul);
    assert(un > ub);
    assert(un > us);
    assert(un > un);
    assert(un > ul);
    assert(ul > ub);
    assert(ul > us);
    assert(ul > un);
    assert(ul > ul);

    assert(!(1 > 2));
    assert(  2 > 1);
    assert(!(-1 >  2));
    assert(   2 > -1 );

    // 1. sizeof(signed) > sizeof(unsigned)
    assert(sl > un);
    assert(un > sl);
    assert(!(-1L >  2 ));
    assert(   2  > -1L );

    // 1b. sizeof(common) > sizeof(either)
    assert(ss > us);
    assert(us > ss);
    assert(!( short(-1) > ushort( 2)));
    assert(  ushort( 2) >  short(-1) );

    // 2. signed.min >= 0
    assert(un > cast(int)2);
    assert(cast(int)2 > un);
    assert(ul > cast(int)2);
    assert(cast(int)2 > ul);
}

void test_ImplicitSignCast()
{
      byte sb;     ubyte ub;
     short ss;    ushort us;
       int sn;      uint un;
      long sl;     ulong ul;

    // 3. unsigned.max < typeof(unsigned.max/2) => ERROR
    assert(sn > cast(uint)2);
    assert(cast(uint)2 > sn);
    assert(cast(int)-1 > cast(uint)3);
    assert(cast(uint)3 > cast(int)-1);
    assert(-1   >  2UL);
    assert( 2UL > -1  );
    // error
    assert(ul > -2);
    assert(-2 > ul);
    assert(sn > ul);
    assert(ul > sn);
    assert(sl > ul);
    assert(ul > sl);
    assert(sn > un);
    assert(un > sn);
}

/+
void main()
{
    uint u;
    int s;

    if (u < -1) {}  // notice
    if (u < 1) {}
    if (s > 1u) {}  // notice


{
     byte   a = -3;
     ubyte  b =  2;
     short  c = -3;
     ushort d =  2;
     int    e = -3;
     uint   f =  2;
     long   g = -3;
     ulong  h =  2;

     assert(a < b);
     assert(c < d);
     assert(e < f); // fails!!
     assert(g < h); // fails!!
     assert(a < h); // fails!!
     assert(b > g);
     assert(d > e);
 }
}
+/
