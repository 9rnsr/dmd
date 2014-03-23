/*
TEST_OUTPUT:
---
fail_compilation/test313a.d(13): Error: undefined identifier writefln
fail_compilation/test313a.d(16): Error: undefined identifier fail313stdio
---
*/
import imports.fail313b;

void main()
{
    // compiler correctly reports "undefined identifier writefln"
    writefln("foo");

    // works fine! --> correctly reports "undefined identifier std"
    imports.fail313stdio.writefln("foo");
}
