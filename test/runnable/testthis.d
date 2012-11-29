// runnable/traits.d    9091,8972,8971,7027
// runnable/test4.d     test6()

template TypeTuple(TL...) { alias TypeTuple = TL; }

/********************************************************/

// test for DsymbolExp::semantic fix
void testwith()
{
    struct S { int a; }
    class C { int a; }
    static assert(!__traits(compiles, { with (S) { int n = a; } }));
    static assert(!__traits(compiles, { with (C) { int n = a; } }));
}

/********************************************************/

mixin("struct S6 {"~aggrDecl~"}");
mixin("class  C6 {"~aggrDecl~"}");
enum aggrDecl =
q{
    alias Type = typeof(this);

    int x = 2;

    void foo()
    {
        static assert( is(typeof(Type.x.offsetof)));
        static assert( is(typeof(Type.x.mangleof)));
        static assert( is(typeof(Type.x.sizeof  )));
        static assert( is(typeof(Type.x.alignof )));
        static assert( is(typeof({ auto n = Type.x.offsetof; })));
        static assert( is(typeof({ auto n = Type.x.mangleof; })));
        static assert( is(typeof({ auto n = Type.x.sizeof;   })));
        static assert( is(typeof({ auto n = Type.x.alignof;  })));
        static assert( is(typeof(Type.x)));
        static assert( is(typeof({ auto n = Type.x; })));
        static assert( __traits(compiles, Type.x));
        static assert( __traits(compiles, { auto n = Type.x; }));

        static assert( is(typeof(x.offsetof)));
        static assert( is(typeof(x.mangleof)));
        static assert( is(typeof(x.sizeof  )));
        static assert( is(typeof(x.alignof )));
        static assert( is(typeof({ auto n = x.offsetof; })));
        static assert( is(typeof({ auto n = x.mangleof; })));
        static assert( is(typeof({ auto n = x.sizeof;   })));
        static assert( is(typeof({ auto n = x.alignof;  })));
        static assert( is(typeof(x)));
        static assert( is(typeof({ auto n = x; })));
        static assert( __traits(compiles, x));
        static assert( __traits(compiles, { auto n = x; }));

        with (this)
        {
            static assert( is(typeof(x.offsetof)));
            static assert( is(typeof(x.mangleof)));
            static assert( is(typeof(x.sizeof  )));
            static assert( is(typeof(x.alignof )));
            static assert( is(typeof({ auto n = x.offsetof; })));
            static assert( is(typeof({ auto n = x.mangleof; })));
            static assert( is(typeof({ auto n = x.sizeof;   })));
            static assert( is(typeof({ auto n = x.alignof;  })));
            static assert( is(typeof(x)));
            static assert( is(typeof({ auto n = x; })));
            static assert( __traits(compiles, x));
            static assert( __traits(compiles, { auto n = x; }));
        }
    }

    static void bar()
    {
        static assert( is(typeof(Type.x.offsetof)));
        static assert( is(typeof(Type.x.mangleof)));
        static assert( is(typeof(Type.x.sizeof  )));
        static assert( is(typeof(Type.x.alignof )));
        static assert( is(typeof({ auto n = Type.x.offsetof; })));
        static assert( is(typeof({ auto n = Type.x.mangleof; })));
        static assert( is(typeof({ auto n = Type.x.sizeof;   })));
        static assert( is(typeof({ auto n = Type.x.alignof;  })));
        static assert( is(typeof(Type.x)));
        static assert(!is(typeof({ auto n = Type.x; })));
        static assert( __traits(compiles, Type.x));
        static assert(!__traits(compiles, { auto n = Type.x; }));

        static assert( is(typeof(x.offsetof)));
        static assert( is(typeof(x.mangleof)));
        static assert( is(typeof(x.sizeof  )));
        static assert( is(typeof(x.alignof )));
        static assert( is(typeof({ auto n = x.offsetof; })));
        static assert( is(typeof({ auto n = x.mangleof; })));
        static assert( is(typeof({ auto n = x.sizeof;   })));
        static assert( is(typeof({ auto n = x.alignof;  })));
        static assert( is(typeof(x)));
        static assert(!is(typeof({ auto n = x; })));
        static assert( __traits(compiles, x));
        static assert(!__traits(compiles, { auto n = x; }));

        Type t;
        with (t)
        {
            static assert( is(typeof(x.offsetof)));
            static assert( is(typeof(x.mangleof)));
            static assert( is(typeof(x.sizeof  )));
            static assert( is(typeof(x.alignof )));
            static assert( is(typeof({ auto n = x.offsetof; })));
            static assert( is(typeof({ auto n = x.mangleof; })));
            static assert( is(typeof({ auto n = x.sizeof;   })));
            static assert( is(typeof({ auto n = x.alignof;  })));
            static assert( is(typeof(x)));
            static assert( is(typeof({ auto n = x; })));
            static assert( __traits(compiles, x));
            static assert( __traits(compiles, { auto n = x; }));
        }
    }
};
void test6()
{
    foreach (Type; TypeTuple!(S6, C6))
    {
        static assert( is(typeof(Type.x.offsetof)));
        static assert( is(typeof(Type.x.mangleof)));
        static assert( is(typeof(Type.x.sizeof  )));
        static assert( is(typeof(Type.x.alignof )));
        static assert( is(typeof({ auto n = Type.x.offsetof; })));
        static assert( is(typeof({ auto n = Type.x.mangleof; })));
        static assert( is(typeof({ auto n = Type.x.sizeof;   })));
        static assert( is(typeof({ auto n = Type.x.alignof;  })));
        static assert( is(typeof(Type.x)));
        static assert(!is(typeof({ auto n = Type.x; })));
        static assert( __traits(compiles, Type.x));
        static assert(!__traits(compiles, { auto n = Type.x; }));

        Type t;
        static assert( is(typeof(t.x.offsetof)));
        static assert( is(typeof(t.x.mangleof)));
        static assert( is(typeof(t.x.sizeof  )));
        static assert( is(typeof(t.x.alignof )));
        static assert( is(typeof({ auto n = t.x.offsetof; })));
        static assert( is(typeof({ auto n = t.x.mangleof; })));
        static assert( is(typeof({ auto n = t.x.sizeof;   })));
        static assert( is(typeof({ auto n = t.x.alignof;  })));
        static assert( is(typeof(t.x)));
        static assert( is(typeof({ auto n = t.x; })));
        static assert( __traits(compiles, t.x));
        static assert( __traits(compiles, { auto n = t.x; }));

        with (t)
        {
            static assert( is(typeof(x.offsetof)));
            static assert( is(typeof(x.mangleof)));
            static assert( is(typeof(x.sizeof  )));
            static assert( is(typeof(x.alignof )));
            static assert( is(typeof({ auto n = x.offsetof; })));
            static assert( is(typeof({ auto n = x.mangleof; })));
            static assert( is(typeof({ auto n = x.sizeof;   })));
            static assert( is(typeof({ auto n = x.alignof;  })));
            static assert( is(typeof(x)));
            static assert( is(typeof({ auto n = x; })));
            static assert( __traits(compiles, x));
            static assert( __traits(compiles, { auto n = x; }));
        }
    }
}

/********************************************************/

void main()
{
}
