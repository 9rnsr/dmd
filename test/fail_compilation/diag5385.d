/*
TEST_OUTPUT:
---
fail_compilation/diag5385.d(19): Error: class imports.fail5385.C member privX is not accessible
fail_compilation/diag5385.d(20): Error: class imports.fail5385.C member packX is not accessible
fail_compilation/diag5385.d(21): Error: class imports.fail5385.C member privX2 is not accessible
fail_compilation/diag5385.d(22): Error: class imports.fail5385.C member packX2 is not accessible
fail_compilation/diag5385.d(23): Error: struct imports.fail5385.S member privX is not accessible
fail_compilation/diag5385.d(24): Error: struct imports.fail5385.S member packX is not accessible
fail_compilation/diag5385.d(25): Error: struct imports.fail5385.S member privX2 is not accessible
fail_compilation/diag5385.d(26): Error: struct imports.fail5385.S member packX2 is not accessible
---
*/

import imports.fail5385;

void main()
{
    C.privX = 1;
    C.packX = 1;
    C.privX2 = 1;
    C.packX2 = 1;
    S.privX = 1;
    S.packX = 1;
    S.privX2 = 1;
    S.packX2 = 1;
}
