/*
TEST_OUTPUT:
---
fail_compilation/mangle1.d(8): Error: can only apply to a single declaration
---
*/

pragma(mangle, "_stuff_") __gshared { int x, y; }
