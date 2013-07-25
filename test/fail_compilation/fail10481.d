/*
TEST_OUTPUT:
---
fail_compilation/fail10481.d(12): Error: undefined identifier T1
fail_compilation/fail10481.d(12):        did you mean public alias 'T0'?
fail_compilation/fail10481.d(16): Error: cannot resolve type for get!(A)
---
*/

struct A {}

void get(T0 = T1.Req, Params...)(Params , T1) {}

void main()
{
    auto xxx = get!A;
}
