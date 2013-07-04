/*
TEST_OUTPUT:
---
fail_compilation/fail10528.d(18): Error: module fail10528 variable fail10528a.g_data is private
fail_compilation/fail10528.d(20): Error: struct fail10528a.S member data is not accessible
fail_compilation/fail10528.d(21): Error: struct fail10528a.S member value is not accessible
fail_compilation/fail10528.d(22): Error: struct fail10528a.S member E is not accessible
fail_compilation/fail10528.d(24): Error: class fail10528a.C member data is not accessible
fail_compilation/fail10528.d(25): Error: class fail10528a.C member value is not accessible
fail_compilation/fail10528.d(26): Error: class fail10528a.C member E is not accessible
---
*/

import imports.fail10528a;

void main()
{
    auto x = g_data; // Error (correct)

    auto y1 = S.data;   // no error (incorrect)
    auto y2 = S.value;  // no error (incorrect)
    auto y3 = S.E.val;  // no error (incorrect)

    auto z1 = C.data;   // no error (incorrect)
    auto z2 = C.value;  // no error (incorrect)
    auto z3 = C.E.val;  // no error (incorrect)
}
