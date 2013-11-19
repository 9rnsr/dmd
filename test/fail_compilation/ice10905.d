/*
TEST_OUTPUT:
---
fail_compilation/ice10905.d(20): Error: incompatible types for ((this.x) == (cast(const(__vector(ulong[2])))[1LU, 1LU])): 'const(__vector(ulong[2]))' and 'const(__vector(ulong[2]))'
---
*/

import core.simd: ulong2;

struct Foo
{
    enum ulong2 y = 1;
}

struct Bar
{
    ulong2 x;
    bool spam() const
    {
        return x == Foo.y;
    }
}

void main() {}
