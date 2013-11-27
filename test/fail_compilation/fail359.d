/*
TEST_OUTPUT:
---
fail_compilation/fail359.d(10): Error: #line integer ["filespec"]\n expected
fail_compilation/fail359.d(11): Error: no identifier for declarator _BOOM
fail_compilation/fail359.d(11): Error: semicolon expected, not 'void'
---
*/

#line 5 _BOOM
void main() { }
