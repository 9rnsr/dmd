/*
TEST_OUTPUT:
---
fail_compilation/fail52.d(13): Error: class fail52.B unable to resolve forward reference in definition
fail_compilation/fail52.d(12): Error: class fail52.A unable to resolve forward reference in definition
fail_compilation/fail52.d(14): Error: class fail52.C unable to resolve forward reference in definition
---
*/

// interface A{void f();}

 class A:B{void f();}
 class B:C{void g();}
 class C:A{void g();}

