/*
TEST_OUTPUT:
---
fail_compilation/ice9284.d(14): Error: template ice9284.C.this cannot deduce template function from argument types !()(int), Candidates are:
fail_compilation/ice9284.d(12):        ice9284.C.this()(string)
fail_compilation/ice9284.d(20): Error: template instance ice9284.C.this!() error instantiating
---
*/

class C
{
    this()(string)
    {
        this(10);
        // delegating to a constructor which not exists.
    }
}
void main()
{
    new C("hello");
}
