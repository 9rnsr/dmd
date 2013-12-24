/*
TEST_OUTPUT:
---
fail_compilation/diag1730.d(38): Error: function diag1730.S.func () is not callable using argument types () inout
fail_compilation/diag1730.d(40): Error: function diag1730.S.iFunc () immutable is not callable using argument types () inout
fail_compilation/diag1730.d(41): Error: function diag1730.S.sFunc () shared is not callable using argument types () inout
fail_compilation/diag1730.d(42): Error: function diag1730.S.scFunc () shared const is not callable using argument types () inout
fail_compilation/diag1730.d(57): Error: function diag1730.S.iFunc () immutable is not callable using argument types ()
fail_compilation/diag1730.d(58): Error: function diag1730.S.sFunc () shared is not callable using argument types ()
fail_compilation/diag1730.d(59): Error: function diag1730.S.scFunc () shared const is not callable using argument types ()
fail_compilation/diag1730.d(62): Error: function diag1730.S.func () is not callable using argument types () const
fail_compilation/diag1730.d(64): Error: function diag1730.S.iFunc () immutable is not callable using argument types () const
fail_compilation/diag1730.d(65): Error: function diag1730.S.sFunc () shared is not callable using argument types () const
fail_compilation/diag1730.d(66): Error: function diag1730.S.scFunc () shared const is not callable using argument types () const
fail_compilation/diag1730.d(69): Error: function diag1730.S.func () is not callable using argument types () immutable
fail_compilation/diag1730.d(72): Error: function diag1730.S.sFunc () shared is not callable using argument types () immutable
fail_compilation/diag1730.d(76): Error: function diag1730.S.func () is not callable using argument types () shared
fail_compilation/diag1730.d(77): Error: function diag1730.S.cFunc () const is not callable using argument types () shared
fail_compilation/diag1730.d(78): Error: function diag1730.S.iFunc () immutable is not callable using argument types () shared
fail_compilation/diag1730.d(81): Error: function diag1730.S.wFunc () inout is not callable using argument types () shared
fail_compilation/diag1730.d(83): Error: function diag1730.S.func () is not callable using argument types () shared const
fail_compilation/diag1730.d(84): Error: function diag1730.S.cFunc () const is not callable using argument types () shared const
fail_compilation/diag1730.d(85): Error: function diag1730.S.iFunc () immutable is not callable using argument types () shared const
fail_compilation/diag1730.d(86): Error: function diag1730.S.sFunc () shared is not callable using argument types () shared const
---
*/
struct S
{
    void func() { }
    void cFunc() const { }
    void iFunc() immutable { }
    void sFunc() shared { }
    void scFunc() shared const { }
    void wFunc() inout { }

    static void test(inout(S) s)
    {
        s.func();   // ng
        s.cFunc();
        s.iFunc();  // ng
        s.sFunc();  // ng
        s.scFunc(); // ng
        s.wFunc();
    }
}

void main()
{
    S obj;
    const(S) cObj;
    immutable(S) iObj;
    shared(S) sObj;
    shared(const(S)) scObj;

    obj.func();
    obj.cFunc();
    obj.iFunc();   // ng
    obj.sFunc();   // ng
    obj.scFunc();  // ng
    obj.wFunc();

    cObj.func();   // ng
    cObj.cFunc();
    cObj.iFunc();  // ng
    cObj.sFunc();  // ng
    cObj.scFunc(); // ng
    cObj.wFunc();

    iObj.func();   // ng
    iObj.cFunc();
    iObj.iFunc();
    iObj.sFunc();  // ng
    iObj.scFunc();
    iObj.wFunc();

    sObj.func();   // ng
    sObj.cFunc();  // ng
    sObj.iFunc();  // ng
    sObj.sFunc();
    sObj.scFunc();
    sObj.wFunc();  // ng

    scObj.func();  // ng
    scObj.cFunc(); // ng
    scObj.iFunc(); // ng
    scObj.sFunc(); // ng
    scObj.scFunc();
    scObj.wFunc(); // ng
}

