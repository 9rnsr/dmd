// REQUIRED_ARGS: -o-
/*
TEST_OUTPUT:
---
fail_compilation/ice13259.d(12): Error: delegate ice13259.__dgliteral6 cannot be module members
fail_compilation/ice13259.d(16): Error: delegate ice13259.X() cannot be module members
fail_compilation/ice13259.d(18): Error: template instance ice13259.X!() error instantiating
fail_compilation/ice13259.d(22): Error: delegate ice13259.C.__dgliteral2 cannot be class members
---
*/

auto dg = delegate {};

template X()
{
    auto dg = delegate {};
}
alias x = X!();

class C
{
    auto dg = delegate {};
}
