/*
TEST_OUTPUT:
---
fail_compilation/fail52.d(12): Error: class fail52.B circular inheritance
fail_compilation/fail52.d(13): Deprecation: overriding base class function without using override attribute is deprecated (fail52.C.g overrides fail52.B.g)
---
*/

// interface A{void f();}

class A : B { void f(); }
class B : C { void g(); }
class C : A { void g(); }
