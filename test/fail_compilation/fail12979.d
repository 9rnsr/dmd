/*
TEST_OUTPUT:
---
fail_compilation/fail12979.d(14): Error: inline assembler not allowed in @safe function fail12979.f12979c!().f12979c
fail_compilation/fail12979.d(25): Error: template instance fail12979.f12979c!() error instantiating
fail_compilation/fail12979.d(19): Error: object.Exception is thrown but not caught
fail_compilation/fail12979.d(17): Error: function 'fail12979.f12979d!().f12979d' is nothrow yet may throw
fail_compilation/fail12979.d(26): Error: template instance fail12979.f12979d!() error instantiating
---
*/

void f12979c()() @safe
{
    asm { nop; }
}

void f12979d()() nothrow
{
    throw new Exception("");
    asm { nop; }
}

void test12979()
{
    f12979c();  // error
    f12979d();  // error
}
