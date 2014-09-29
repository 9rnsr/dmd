/*
TEST_OUTPUT:
---
fail_compilation/fail327.d(10): Error: inline assembler not allowed in @safe function fail327.foo
---
*/

@safe void foo()
{
    asm { xor EAX,EAX; }
}
