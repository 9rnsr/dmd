/*
TEST_OUTPUT:
---
fail_compilation/ice9284.d(14): Error: template ice9284.C.__ctor does not match function template declaration
fail_compilation/ice9284.d(14): Error: template ice9284.C.__ctor()(string) cannot deduce template function from argument types !()(int)
fail_compilation/ice9284.d(20): Error: template instance ice9284.C.__ctor!() error instantiating
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
