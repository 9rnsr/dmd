/*
TEST_OUTPUT:
---
fail_compilation/fail276.d(13): Error: variable this forward referenced
fail_compilation/fail276.d(13): Error: variable this forward referenced
---
*/

class C
{
    this()
    {
        auto i = new class()
        {
            auto k = new class()
            {
                void func()
                {
                    this.outer.outer;
                }
            };
        };
    }
    int i;
}
void main() {}
