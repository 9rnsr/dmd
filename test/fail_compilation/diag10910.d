/*
TEST_OUTPUT:
---
fail_compilation/diag10910.d(14): Error: string index 17 is out of bounds [0 .. 6]
fail_compilation/diag10910.d(15): Error: string index 12 is out of bounds [0 .. 3]
fail_compilation/diag10910.d(16): Error: string index 9 is out of bounds [0 .. 6]
fail_compilation/diag10910.d(17): Error: string index 218 is out of bounds [0 .. 2]
fail_compilation/diag10910.d(19): Error: string index 356 is out of bounds [0 .. 5]
fail_compilation/diag10910.d(22): Error: string slice [14 .. 16] is out of bounds
---
*/
void main()
{
    char c = "abcdef"[17];
    char [7] x = "abc"[12];
    int ww = "abc"["dsdffg"[9]];
    int m = new int["as"[218]];
    auto aa = [0:0];
    aa.remove("dgffs"[356]);

    void bug(string y) {}
    bug("sdgdf"[14..16]);

/*
TEST_OUTPUT:
---
fail_compilation/diag10910.d(31): Error: string index 17 is out of bounds [0 .. 6]
---
*/
    Object o;
    o = "abcdef"[17];
}
