struct S {}

void foo   (scope ref S s) {}
auto hoo(T)(scope ref T s) {}

int bar   (scope ref S s) { return 1; }
int bar   (          S s) { return 3; }
int var(T)(scope ref T s) { return 1; }
int var(T)(          T s) { return 3; }

// 'scope ref' parameter is mangled as same as 'ref' parameter.
// So linker will raise "Previous Definition Different" error.
int baw   (scope ref S s) { return 1; }
int baw   (      ref S s) { return 2; }
int vaw(T)(scope ref T s) { return 1; }
int vaw(T)(      ref T s) { return 2; }

// 'scope ref' parameter is mangled as same as 'ref' parameter.
// So linker will raise "Previous Definition Different" error.
int bay(scope ref S s) { return 1; }
int bay(      ref S s) { return 2; }
int bay(         S s) { return 3; }

struct S1 { int n; }
struct S2 { this(int n){} }
void baz(ref S1 s) {}
void vaz(ref S2 s) {}

bool testautoref()
{
    S s;

    // 'scope ref' can bind both lvalue and rvalue
    foo(s  );
    foo(S());
    // 'scope ref' and template function also can do.
    hoo(s  );
    hoo(S());
    // 'scope ref' does not depends on IFTI
    alias hoo!S Hoo;
    Hoo(s  );
    Hoo(S());

    // overload resolution between 'scope ref' and non-ref
    // 'scope ref' is always lesser matching.
    assert(bar(s  ) == 1);
    assert(bar(S()) == 3);
    assert(var(s  ) == 1);
    assert(var(S()) == 3);

    //alias var!S Var;  // cannot make alias to overload set
        // that instantiated by different function templates.
    //assert(Var(s  ) == 1);
    //assert(Var(S()) == 2);

    // overload resolution between 'scope ref' and 'ref'
    // 'scope ref' is always lesser matching.
    assert(baw(s  ) == 2);
    assert(baw(S()) == 1);
    assert(vaw(s  ) == 2);
    assert(vaw(S()) == 1);

    // overload resolution between 'scope ref', 'ref', and non-ref
    // 'scope ref' is always lesser matching, then *never matches anything*.
    assert(bay(s  ) == 2);
    assert(bay(S()) == 3);

    // keep right behavior: rvalues never matches to 'ref'
    static assert(!__traits(compiles, baz(S1(1)) ));
    static assert(!__traits(compiles, vaz(S2(1)) ));

    return true;
}

void main()
{
    testautoref();
    static assert(testautoref());   // CTFE
}
