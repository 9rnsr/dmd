/*
TEST_OUTPUT:
---
fail_compilation/fail104.d(26): Error: template instance P!() P is not a template declaration, it is a struct
fail_compilation/fail104.d(26): Error: mixin fail104.C!(S).C.T!() is not defined
fail_compilation/fail104.d(31): Error: template instance fail104.C!(S) error instantiating
---
*/

// Issue 76 - Using a non-template struct as a template
// Compiling leads to "Assertion failure: 's->parent' on line 1694 in file
// 'template.c'"

struct S
{
    template T()
    {
        void x(int i)
        {
        }
    }
}

class C(P)
{
    mixin P!().T!();
}

int main(char[][] args)
{
    auto c = new C!(S);

    return 0;
}

