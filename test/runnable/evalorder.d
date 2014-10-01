extern(C) int printf(const char*, ...);
import core.vararg;

string order = "";
void assertOrder(string expected, string fn = __FILE__, size_t ln = __LINE__)
{
    import core.exception;
    if (order != expected)
        throw new AssertError("expected '" ~ expected ~ "', got '" ~ order ~ "'", fn, ln);
    order = "";
}

int[4] arrbuf;
ref int[4] a() { order ~= 'a'; return arrbuf; }
    int[4] b() { order ~= 'b'; return [7,7,7,7]; }
    int[4] c() { order ~= 'c'; return [2,2,2,2]; }  // a /= b - c; => c != b

int valbuf;
ref int x() { order ~= 'x'; return valbuf; }
    int y() { order ~= 'y'; return 7; }
    int z() { order ~= 'z'; return 2; }             // a /= b - c; => c != b

extern(C)
{
    auto fcA()              { order ~= 'A'; return 1; }
    auto fcB()              { order ~= 'B'; return 1; }
    auto fcC()              { order ~= 'C'; return 1; }
    auto fcD(int, int, int) { order ~= 'D'; return 1; }
    auto fcE()              { order ~= 'E'; return &fcD; }
    auto fcV(int, ...)      { order ~= 'V'; return 1; }
}
extern(D)
{
    auto fdA()              { order ~= 'A'; return 1; }
    auto fdB()              { order ~= 'B'; return 1; }
    auto fdC()              { order ~= 'C'; return 1; }
    auto fdD(int, int, int) { order ~= 'D'; return 1; }
    auto fdE()              { order ~= 'E'; return &fdD; }
    auto fdV(int, ...)      { order ~= 'V'; return 1; }
    auto fdW(...)           { order ~= 'W'; return 1; }
    auto fdX(int[] ...)     { order ~= 'X'; return 1; }
}

/******************************************/
// Array OP evaluation order tests

void testArrayOps()
{
    string gen()
    {
        string result;
        void writeln(string[] a...)
        {
            foreach (s; a)
                result ~= s;
            result ~= "\n";
        }

        string[] op1s = ["=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|="];

        writeln("// Binary array ops");
        string checkBin = `assertOrder("abc");`;
        foreach (string op1; op1s)
        {
            foreach (string op2; ["+", "-", "*", "/", "%", "^", "&", "|"])
            {
                writeln("a()[] ", op1, " y()   ", op2, " z();");    writeln(`assertOrder("ayz");`, "\n");
                writeln("a()[] ", op1, " b()[] ", op2, " z();");    writeln(`assertOrder("abz");`, "\n");
                writeln("a()[] ", op1, " y()   ", op2, " c()[];");  writeln(`assertOrder("ayc");`, "\n");
                writeln("a()[] ", op1, " b()[] ", op2, " c()[];");  writeln(`assertOrder("abc");`, "\n");
            }
        }

        writeln("// Unary array ops");
        string checkUna = `assertOrder("ac");`;
        foreach (string op1; op1s)
        {
            foreach (string op2; ["-", "~"])
            {
                writeln("a()[] ", op1, " ", op2, "z();");   writeln(`assertOrder("az");`, "\n");
                writeln("a()[] ", op1, " ", op2, "c()[];"); writeln(`assertOrder("ac");`, "\n");
            }
        }

        return result;
    }
    //pragma(msg, gen());
    mixin(gen());
}

/******************************************/
// Assignment evaluation order tests

void testAssign()
{
    x() = z();
    assertOrder("xz");

    x() = y() + z();
    assertOrder("xyz");
}

/******************************************/
// Function call evaluation order tests

void testCall()
{
    fcD(fcA(), fcB(), fcC());
    assertOrder("ABCD");

    x() = fcD(fcA(), fcB(), fcC());
    assertOrder("xABCD");

    x() = fcD(fcA(), fcB() + y(), fcC());
    assertOrder("xAByCD");

    x() = fcE()(fcA(), fcB() + y(), fcC());
    assertOrder("xEAByCD");

    x() = fcV(fcA(), fcB() + y(), fcC());
    assertOrder("xAByCV");


    fdD(fdA(), fdB(), fdC());
    assertOrder("ABCD");

    x() = fdD(fdA(), fdB(), fdC());
    assertOrder("xABCD");

    x() = fdD(fdA(), fdB() + y(), fdC());
    assertOrder("xAByCD");

    x() = fdE()(fdA(), fdB() + y(), fdC());
    assertOrder("xEAByCD");

    x() = fdV(fdA(), fdB() + y(), fdC());
    assertOrder("xAByCV");

    x() = fdW(fdA(), fdB() + y(), fdC());
    assertOrder("xAByCW");

    x() = fdX(fdA(), fdB() + y(), fdC());
    assertOrder("xAByCX");
}

/******************************************/

int main()
{
    testArrayOps();
    testAssign();
    testCall();

    printf("Success\n");
    return 0;
}
