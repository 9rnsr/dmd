/*
TEST_OUTPUT:
---
fail_compilation/fail257.d(9): Error: incompatible types for (("foo"d) == ("bar"c)): 'immutable(dchar)[]' and 'string'
fail_compilation/fail257.d(9):        while evaluating pragma(msg, (__error) ? "A" : "B")
---
*/

pragma(msg, "foo"d == "bar"c ? "A" : "B");
