/*
TEST_OUTPUT:
---
fail_compilation/fail61.d(24): Error: no property 'B' for type 'fail61.A.B'
fail_compilation/fail61.d(24):        did you mean public variable 'fail61.A.B.C'?
fail_compilation/fail61.d(25): Error: no property 'B' for type 'fail61.A.B'
fail_compilation/fail61.d(25):        did you mean public variable 'fail61.A.B.C'?
fail_compilation/fail61.d(34): Error: no property 'A2' for type 'fail61.B2'
fail_compilation/fail61.d(43): Error: this for foo needs to be type B3 not type fail61.C3
---
*/

class A
{
    class B : A
    {
        static const int C = 5;
    }
}

void main()
{
    int n1 = A.B.C;
    int n2 = A.B.B.C;       // Line24
    int n3 = A.B.B.B.C;     // Line25
}

class A2 { void foo(){ assert(0);} }
class B2 : A2 { override void foo(){} }
class C2 : B2
{
    void bar()
    {
        B2.A2.foo();        // Line34
    }
}

class B3 { void foo(){ assert(0); } }
class C3
{
    void bar()
    {
        B3.foo();           // Line43
    }
}
