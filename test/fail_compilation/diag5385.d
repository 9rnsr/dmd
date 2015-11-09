/*
TEST_OUTPUT:
---
fail_compilation/diag5385.d(3): Error: variable imports.fail5385.C.privX is not accessible from module diag5385
fail_compilation/diag5385.d(4): Error: variable imports.fail5385.C.packX is not accessible from module diag5385
fail_compilation/diag5385.d(5): Error: variable imports.fail5385.C.privX2 is not accessible from module diag5385
fail_compilation/diag5385.d(6): Error: variable imports.fail5385.C.packX2 is not accessible from module diag5385
fail_compilation/diag5385.d(7): Error: variable imports.fail5385.S.privX is not accessible from module diag5385
fail_compilation/diag5385.d(8): Error: variable imports.fail5385.S.packX is not accessible from module diag5385
fail_compilation/diag5385.d(9): Error: variable imports.fail5385.S.privX2 is not accessible from module diag5385
fail_compilation/diag5385.d(10): Error: variable imports.fail5385.S.packX2 is not accessible from module diag5385
---
*/

import imports.fail5385;

#line 1
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
