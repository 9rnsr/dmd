/*
TEST_OUTPUT:
---
fail_compilation/ice2603.d(17): Error: Array operation [1, 2, 3] - [1, 2, 3] not implemented
fail_compilation/ice2603.d(20): Error: Array operation "a" - "b" not implemented
---
*/

// Issue 2603 - ICE(cgcs.c) on subtracting string literals

// 2603. D1+D2. Internal error: ..\backend\cgcs.c 358
/* PATCH: elem *MinExp::toElem(IRState *irs)
just copy code from AddExp::toElem, changing OPadd into OPmin.
*/
void main()
{
    auto c1 = [1,2,3] - [1,2,3];

    // this variation is wrong code on D2, ICE ..\ztc\cgcs.c 358 on D1.
    string c2 = "a" - "b";
}
