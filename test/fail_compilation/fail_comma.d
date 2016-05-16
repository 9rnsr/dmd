int f() { return 1; }
int g() { return 2; }
int h(int) { return 3; }
void voidfunc() {}

struct S
{
    int v;

    int foo(T)() { return 1; }
}

class C
{
    this(int) {}

    class N
    {
        new (size_t n, int) { return null; }
    }
}

void testStmts()
{
    int a, b;
    Object o = new Object();

    f(), g();                       // OK, ExpStatement.exp

    mixin((f(), "f();"));           // NG, CompileStatement.exp

    while (++a, a < 10) {}          // NG, WhileStatement.condition == ForStatement.condition

    do {} while (++a, a < 10);      // NG, DoStatement.condition

    for (int i = 0, j = 1;
         i < 1, j < 10;             // NG, ForStatement.condition
         i++, j++) {}               // OK, ForStatement.increment

    foreach (i; (f(), [1])) {}      // NG, ForeachStatement.aggr

    foreach (i; (f(), 1)            // NG, ForeachRangeStatement.lwr
             .. (g(), 2)) {}        // NG, ForeachRangeStatement.upr

    if (f(), true) {}               // NG, IfStatement.condition

    pragma(msg, (f(), "abc"));      // NG, PragmaStatement.args

    static assert((f(), true));     // NG, StaticAssert.exp

    switch (f(), g())               // NG, SwitchStatement.condition
    {
        case 1:
        case 2, 3:                  // OK, Two Cases
        case (4, 5):                // NG, CaseStatement.exp
        case (6, 7): ..             // NG, CaseRangeStatement.firsr
        case (8, 9):                // NG, CaseRangeStatement.last
            goto case (4, 5);       // NG, GotoCaseStatement.exp
        default:
    }

    // NG, ReturnStatement.exp (1)
    int testReturn1() { return (1, 2); }
    // NG, ReturnStatement.exp (2)
    // For generic code, conservatively disallow comma use always on,
    // ReturnStatement.exp, even though the return type could be void.
    auto testReturn2(alias foo)() { return (f(), foo()); }
    testReturn2!f();
    testReturn2!voidfunc();

    synchronized (f(), o) {}        // NG, SynchronizedStatement.exp

    with (f(), o) {}                // NG, WithStatement.exp

    throw (f(), new Exception("")); // NG, ThrowStatement.exp
}

void testExprs()
{
    int a, b;
    int[] arr = [1, 2, 3];

    a = [(f(), 2)][0];              // NG, ArrayLiteralExp.elements
    a = [(f(), 1):                  // NG, AssocArrayLiteralExp.keys
         (g(), 2)][1];              // NG, AssocArrayLiteralExp.values

    auto s = S((f(), 1));           // NG, StructLiteralExp.elements

    auto c = new C((f(), 1));       // NG, NewExp.arguments
    auto n = (f(), c).new(          // NG, NewExp.thisexp
             (g(), 2)) N();         // NG, NewExp.newargs

    auto ti = typeid((f(), c));     // NG, TypeidExp.obj

    a = mixin((f(), "f()"));        // NG, CompileExp.e1

    assert((f(), true),             // NG, AssertExp.e1
           (g(), "msg"));           // NG, AssertExp.msg

    a = (f(), s).v;                 // NG, DotIdExp.e1

    a = (f(), s).foo!int();         // NG, DotTemplateInstanceExp.e1

    (f(), g)();                     // NG, CallExp.e1
    h((f, g()));                    // NG, CallExp.arguments

    b = *(f(), &a);                 // NG, PtrExp.e1

    b = -(f(), a);                  // NG, NegExp.e1
    b = +(f(), a);                  // NG, UaddExp.e1
    b = ~(f(), a);                  // NG, ComExp.e1
    b = !(f(), false);              // NG, NotExp.e1

    delete (f(), c);                // DeleteExp.e1

    b = cast(int)(f(), arr.length); // CastExp.e1

    a = (f(), arr)[                 // NG, SliceExp.e1
        (f(), 1) ..                 // NG, SliceExp.lwr
        (g(), 2)                    // NG, SliceExp.upr
    ][h(1)];

    ((f(), h(1)),                   // CommaExp.e1
     (g(), voidfunc()));            // CommaExp.e2

    a = (f(), arr)[                 // NG, IndexExp.e1
        (f(), g())                  // NG, IndexExp.e2
    ];

    (f(), a)++;                     // NG, PostExp.e1
    --(f(), a);                     // NG, PreExp.e1

    (f(), a) = 1;                   // NG, AssignExp.e1
    a = (f(), g());                 // NG, AssignExp.e2
    a = f(), g();                   // OK, comma is on on ExpStatement.exp

    (f(), a) +=                     // NG, BinAssignExp.e1
                (g(), 1);           // NG, BinAssignExp.e2
    (f(), a) ^^=                    // NG, PowAssignExp.e1
                 (g(), 1);          // NG, PowAssignExp.e2
    (f(), arr) ~=                   // NG, CatAssignExp.e1
                  (g(), b);         // NG, CatAssignExp.e2

    a = (f(), 1) +                  // NG, AddAssignExp.e1
        (g(), 2);                   // NG, AddAssignExp.e2
    a = (f(), 1) -                  // NG, AddAssignExp.e1
        (g(), 2);                   // NG, AddAssignExp.e2
    arr = (f(), [1]) ~              // NG, CatAssignExp.e1
          (g(), [2]);               // NG, CatAssignExp.e2
}
