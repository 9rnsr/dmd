/*
TEST_OUTPUT:
---
fail_compilation/diag9191.d(20): Error: function diag9191.C1.aaa does not override any function
fail_compilation/diag9191.d(20):        did you mean public function 'diag9191.B1.aa'?
fail_compilation/diag9191.d(25): Error: function diag9191.C2.aaa does not override any function
fail_compilation/diag9191.d(25):        did you mean public function 'diag9191.I1.a'?
fail_compilation/diag9191.d(35): Error: function diag9191.C3.foo does not override any function
fail_compilation/diag9191.d(35):        did you mean public function 'diag9191.B2._foo'?
fail_compilation/diag9191.d(40): Error: function diag9191.C4.toStringa does not override any function
fail_compilation/diag9191.d(40):        did you mean public function 'object.Object.toString'?
---
*/

interface I1 { void a(); }
class B1 { void aa(); }

class C1 : B1, I1
{
    override void aaa();
}

class C2 : I1
{
    override void aaa();
}

class B2
{
    void _foo(){}
}

class C3 : B2
{
    override void foo(){}
}

class C4
{
    override void toStringa(){}
}

void main()
{
}
