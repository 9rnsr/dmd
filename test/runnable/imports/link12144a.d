struct S1 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S2 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S3 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S4 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S5 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S6 { int opCmp(T : typeof(this))(T) { return 0; } }
struct S7 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S8 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S9 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S10 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S11 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S12 { bool opEquals(T : typeof(this))(T) { return false; } }
struct S13 { bool opEquals(T : typeof(this))(T) { return false; } }

void fun()()
{
    { auto a = new S1[1]; }
    { S2[] a; a.length = 10; }
    { S3[] a = [S3.init]; }
    { S4[] a = []; }
    { auto ti = typeid(S5[int]); }
    { auto ti = typeid(int[S6]); }
    { auto ti = typeid(S7[]); }
    { auto ti = typeid(S8*); }
    { auto ti = typeid(S9[3]); }
    { auto ti = typeid(S10 function()); }
    { auto ti = typeid(S11 delegate()); }
    { auto ti = typeid(void function(S12)); }   // TypeInfo_Function doesn't have parameter types
    { auto ti = typeid(void delegate(S13)); }   // ditto
}
