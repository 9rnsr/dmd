/*
TEST_OUTPUT:
---
fail_compilation/fail258.d(12): Error: delimiter cannot be whitespace
fail_compilation/fail258.d(12): Error: delimited string must end in 
"
fail_compilation/fail258.d(12): Error: Declaration expected, not '"X"'
fail_compilation/fail258.d(15): Error: unterminated string constant starting at fail_compilation/fail258.d(15)
---
*/

q"
X

X"

