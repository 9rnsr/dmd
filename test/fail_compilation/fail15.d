/*
TEST_OUTPUT:
---
fail_compilation/fail15.d(27): Error: mixin Test!() xs;

 must be an array or pointer type, not void
---
*/

/*
Segfault on DMD 0.095
http://www.digitalmars.com/d/archives/digitalmars/D/bugs/926.html
*/
module test;

template Test()
{
    bool opIndex(bool x)
    {
        return !x;
    }
}

void main()
{
    mixin Test!() xs;
    bool x = xs[false];
}


