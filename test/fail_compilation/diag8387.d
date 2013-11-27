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


struct S1
{
    template opDispatch(string s) if (s == "x" || s == "y" || s == "f")
    {
        int opDispatch(T)()
        {
            nonExistent;
            return 0;
        }
    }
    //alias y = opDispatch!("y");
}

struct S2
{
    template opDispatch(string s) if (s == "X" || s == "Y" || s == "F")
    {
        int opDispatch(T)()
        {
            nonExistent;
            return 0;
        }
    }
}

@property auto x(T, S)(S s) { return 1024; }

void main()
{
    // Matches to opDispatch signature, so should show errors in opDispatch body
    S1 s1;
    auto x1 = s1.x!int;
    //auto y1 = s1.y!int;   // --> OK
//    auto z1 = s1.f!int();

//    // does not match to opDispatch signature, so instantiation error should appear
//    S2 s2;
//    auto x2 = s2.x!int;
//    auto y2 = s2.y!int;
//    auto z2 = s2.f!int();
}
/+
struct Fail10546a
{
    void opDispatch(string s)()
    {
        //static assert(false, "Tried to call a method on Fail1");
        int x = "str";
    }
}

struct Fail10546b
{
    void opDispatch(string s, T)(T arg)
    {
        //static assert(false, "Tried to call a method on Fail2");
        int x = "str";
    }
}

void test10546()
{
    auto a = Fail10546a();
    a.func();  // "no property" error instead of static asset failure

    auto b = Fail10546b();
    b.func(1); // "no property" error instead of static asset failure
}