/*
TEST_OUTPUT:
---
fail_compilation/diag8387.d(17): Error: undefined identifier nonExistent
fail_compilation/diag8387.d(38): Error: template instance diag8387.S1.opDispatch!"y" error instantiating
fail_compilation/diag8387.d(17): Error: undefined identifier nonExistent
fail_compilation/diag8387.d(39): Error: template instance diag8387.S1.opDispatch!"f" error instantiating
fail_compilation/diag8387.d(44): Error: template instance opDispatch!"y" does not match template declaration opDispatch(string s)() if (s == "X" || s == "Y" || s == "F")
fail_compilation/diag8387.d(45): Error: template instance opDispatch!"f" does not match template declaration opDispatch(string s)() if (s == "X" || s == "Y" || s == "F")
---
*/

struct S1
{
    int opDispatch(string s)() if (s == "x" || s == "y" || s == "f")
    {
        nonExistent;
        return 1;
    }
}

struct S2
{
    int opDispatch(string s)() if (s == "X" || s == "Y" || s == "F")
    {
        nonExistent;
        return 1;
    }
}

@property auto x(T)(T t) { return 2; }

void main()
{
    // Matches to opDispatch signature, so should show errors in opDispatch body
    S1 s1;
    auto x1 = s1.x; // matches to UFCS function, so no error occur
    auto y1 = s1.y;
    auto z1 = s1.f();

    // does not match to opDispatch signature, so instantiation error should appear
    S2 s2;
    auto x2 = s2.x; // matches to UFCS function, so no error occur
    auto y2 = s2.y;
    auto z2 = s2.f();
}
