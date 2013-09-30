// REQUIRED_ARGS: -de
/*
TEST_OUTPUT:
---
fail_compilation/dep1.d(13): Deprecation: class dep1.C is deprecated
---
*/

deprecated class C {}

void main()
{
    auto c = new C();
}
