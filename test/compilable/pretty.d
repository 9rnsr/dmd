// REQUIRED_ARGS: -o-
// PERMUTE_ARGS:

template TypeTuple(T...) { alias TypeTuple = T; }

/***************************************************/
// 1748 class template with stringof

struct S1748(T) {}
static assert(S1748!int.stringof == "S1748!int");

class C1748(T) {}
static assert(C1748!int.stringof == "C1748!int");

/***************************************************/
// 14067 - enum members with stringof

enum E14067 { a }

static assert(E14067.a.stringof == "E14067.a");
enum var14067 = E14067.a;
static assert(var14067.stringof == "E14067.a");

struct S14067(E14067 e) {}
static assert(S14067!(E14067.a).stringof == "S14067!(E14067.a)");

/***************************************************/
// 9565 - remove platform-specific suffix from indices and bounds

void test9565()
{
    bool startsWith(string s, string m) { return s[0 .. m.length] == m; }

    enum string castPrefix = "cast(" ~ size_t.stringof ~ ")";

    // TypeSArray
    static assert((int[10]).stringof == "int[10]", T.stringof);

    int[] arr;

    // IndexExp
    {
        // index == IntegerExp
        static assert((arr[ 4  ]).stringof == "arr[4]");
        static assert((arr[ 4U ]).stringof == "arr[4]");
        static assert((arr[ 4L ]).stringof == "arr[4]");
        static assert((arr[ 4LU]).stringof == "arr[4]");

        // index == UAddExp
        static assert((arr[+4  ]).stringof == "arr[4]");
        static assert((arr[+4U ]).stringof == "arr[4]");
        static assert((arr[+4L ]).stringof == "arr[4]");
        static assert((arr[+4LU]).stringof == "arr[4]");

        // index == NegExp
        static assert((arr[-4  ]).stringof == "arr[" ~ castPrefix ~ "-4]");
        static assert((arr[-4U ]).stringof == "arr[4294967292]");
        static assert((arr[int.min] ).stringof == "arr[" ~ castPrefix ~ "-2147483648]");
      static if (is(size_t == ulong))
      {
        static assert((arr[-4L ]).stringof == "arr[" ~ castPrefix ~ "-4L]");
        static assert((arr[-4LU]).stringof == "arr[-4LU]");

        // IntegerLiteral needs suffix if the value is greater than long.max
        static assert((arr[long.max + 0]).stringof == "arr[9223372036854775807]");
        static assert((arr[long.max + 1]).stringof == "arr[" ~ castPrefix ~ "(9223372036854775807L + 1L)]");
      }

        foreach (Int; TypeTuple!(byte, ubyte, short, ushort, int, uint, long, ulong))
        {
            enum Int p4 = +4;
            enum string result1 = (arr[p4]).stringof;
            static assert(result1 == "arr[4]");

            enum string result2 = (arr[cast(Int)+4]).stringof;
            static assert(result2 == "arr[4]");
        }
        foreach (Int; TypeTuple!(byte, short, int, long))
        {
            // keep "cast(Type)" in the string representation

            enum Int m4 = -4;
            static if (is(typeof({ size_t x = m4; })))
            {
                enum string result1 = (arr[m4]).stringof;
                static assert(startsWith(result1, "arr[" ~ castPrefix));
            }
            else
                static assert(!__traits(compiles, arr[m4]));

            enum string result2 = (arr[cast(Int)-4]).stringof;
            static assert(startsWith(result2, "arr[" ~ castPrefix));
        }
    }

    // SliceExp
    {
        // lwr,upr == IntegerExp
        static assert((arr[4   .. 8  ]).stringof == "arr[4..8]");
        static assert((arr[4U  .. 8U ]).stringof == "arr[4..8]");
        static assert((arr[4L  .. 8L ]).stringof == "arr[4..8]");
        static assert((arr[4LU .. 8LU]).stringof == "arr[4..8]");

        // lwr,upr == UAddExp
        static assert((arr[+4   .. +8  ]).stringof == "arr[4..8]");
        static assert((arr[+4U  .. +8U ]).stringof == "arr[4..8]");
        static assert((arr[+4L  .. +8L ]).stringof == "arr[4..8]");
        static assert((arr[+4LU .. +8LU]).stringof == "arr[4..8]");
    }
}
