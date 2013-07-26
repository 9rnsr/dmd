/*
TEST_OUTPUT:
---
fail_compilation/fail8631.d(15): Error: function fail8631.D.foo does not override any function
fail_compilation/fail8631.d(15):        did you mean public function 'fail8631.B.foo'?
---
*/

class B {
    int foo() immutable { return 2; }
    int foo() const { return 2; }
}
class D : B {
    override int foo() immutable { return 2; }
    override int foo() const shared { return 2; }   // doesn't override any
    override int foo() const { return 2; }
}
