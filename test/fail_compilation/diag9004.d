/*
TEST_OUTPUT:
---
fail_compilation/diag9004.d(8): Error: template diag9004.bar does not match function template declaration
fail_compilation/diag9004.d(8): Error: template diag9004.bar(FooT)(FooT foo, FooT.T x) cannot deduce template function from argument types !()(Foo!int, int)
---
*/

#line 1
struct Foo(_T) {
    alias _T T;
}
void bar(FooT)(FooT foo, FooT.T x) {
}
void main() {
    Foo!int foo;
    bar(foo, 1); // line 8
}
