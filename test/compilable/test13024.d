
// 13024
enum A { a }
enum B { b }
struct T { A x; B y; }
void main()
{
    T t;
    auto r1 = [cast(int)(t.x), cast(int)(t.y)]; // OK
    auto r2 = [t.tupleof]; // crash
    auto r3 = [t.x, t.y]; // crash

    static assert(is(typeof(true ? t.x : t.y) == int));
}

// ----

enum REGSAM
{
    KEY_QUERY_VALUE         = 0x0001,   /// Permission to query subkey data
    KEY_WOW64_RES           = 0x0300,   ///
}
private REGSAM compatibleRegsam(in REGSAM samDesired)
{
    static bool isWow64;
    return isWow64 ? samDesired : cast(REGSAM)(samDesired & ~REGSAM.KEY_WOW64_RES);
}

// ----

immutable size_t CACHELIMIT;   // Half the size of the data cache.

void mulInternal(const(int)[] y) pure nothrow
{
    auto chunksize = CACHELIMIT / y.length;
    static assert(is(typeof(chunksize) == size_t));
}
