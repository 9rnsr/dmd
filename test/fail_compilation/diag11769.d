/*
TEST_OUTPUT:
---
fail_compilation/diag11769.d(18): Error: diag11769.foo!string.bar called with argument types (string) matches both:
	fail_compilation/diag11769.d(13): bar(immutable(wchar)[])
and:
	fail_compilation/diag11769.d(14): bar(immutable(dchar)[])
---
*/

template foo(T)
{
    void bar(wstring) {}
    void bar(dstring) {}
}
void main()
{
    foo!string.bar("abc");
}
