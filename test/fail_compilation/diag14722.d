/*
TEST_OUTPUT:
---
fail_compilation/diag14722.d(9): Error: template diag14722.Foo() is used as a type
---
*/

class Foo() {}
Foo f;
