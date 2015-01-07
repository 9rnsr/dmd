/*
TEST_OUTPUT:
---
fail_compilation/fail236.d(13): Error: undefined identifier x
fail_compilation/fail236.d(21):        instantiated from here: fail236.Templ2!()(int)
---
*/

// Issue 870 - contradictory error messages for templates

template Templ2(alias a)
{
    void Templ2(x)
    {
    }
}

void main()
{
    int i;
    Templ2(i);
}
