/*
TEST_OUTPUT:
---
fail_compilation/fail236.d(14): Error: undefined identifier x
fail_compilation/fail236.d(22): Error: template fail236.Templ2 cannot deduce template function from argument types !()(int), Candidates are:
fail_compilation/fail236.d(12):        fail236.Templ2(alias a)(x)
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
