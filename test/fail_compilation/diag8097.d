/*
TEST_OUTPUT:
---
fail_compilation/diag8097.d(25): Error: no property 'bal' for type 'S', did you mean 'val'?
fail_compilation/diag8097.d(26): Error: no property 'bar' for type 'S'
fail_compilation/diag8097.d(31): Error: no property 'bar' or matches opDispatch template for type 'T'
---
*/

struct S
{
    int val;
}

struct T
{
    int val;
    int opDispatch(string s)() if (s == "foo") { return 0; }
}

void main()
{
    S s;
    auto x1 = s.val; // OK
    auto x2 = s.bal; // NG - spellchecker
    auto x3 = s.bar; // NG - no spell checker

    T t;
    auto y1 = t.val; // OK
    auto y2 = t.foo; // OK
    auto y3 = t.bar; // --> better error
}
