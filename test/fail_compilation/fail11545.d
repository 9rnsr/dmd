/*
TEST_OUTPUT:
---
fail_compilation/fail11545.d(14): Error: 'this' is only defined in non-static member functions, not __funcliteral4
fail_compilation/fail11545.d(18): Error: 'this' is only defined in non-static member functions, not __lambda5
---
*/

class C
{
    int x = 42;

    int function() f1 = function() {
        return x;
    };

    int function() f2 = {
        return x;
    };
}
