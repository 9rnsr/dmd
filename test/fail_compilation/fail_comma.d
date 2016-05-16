int f() { return 1; }
int g() { return 2; }
int h(int) { return 3; }
void voidfunc() {}

void testStmts()
{
    int a, b;
    Object o = new Object();

    f(), g();                       // OK, ExpStatement.exp

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
    int[3] arr;
    //Object o = new Object();

    (f(), a) = 1;                   // NG, AssignExp.e1

    a = (f(), g());                 // NG, AssignExp.e2
    a = f(), g();                   // OK, comma is on on ExpStatement.exp

    (f(), g)();                     // NG, CallExp.e1
    h((f, g()));                    // NG, CallExp.arguments

    a = (f(), arr)[                 // NG, IndexExp.e1
        (f(), g())                  // NG, IndexExp.e2
    ];

    a = (f(), arr)[                 // NG, SliceExp.e1
        (f(), 1) ..                 // NG, SliceExp.lwr
        (g(), 2)                    // NG, SliceExp.upr
    ][h(1)];
}
