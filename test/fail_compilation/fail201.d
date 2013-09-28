/*
TEST_OUTPUT:
---
fail_compilation/fail201.d(21): Error: shift by 33 is outside the range 0..31
fail_compilation/fail201.d(21): Error: shift by 33 is outside the range 0..31
fail_compilation/fail201.d(22): Error: shift by 33 is outside the range 0..31
fail_compilation/fail201.d(22): Error: shift by 33 is outside the range 0..31
fail_compilation/fail201.d(23): Error: shift by 33 is outside the range 0..31
fail_compilation/fail201.d(23): Error: shift by 33 is outside the range 0..31
fail_compilation/fail201.d(25): Error: shift assign by 33 is outside the range 0..31
fail_compilation/fail201.d(26): Error: shift assign by 33 is outside the range 0..31
fail_compilation/fail201.d(27): Error: shift assign by 33 is outside the range 0..31
---
*/

// Issue 1601 - shr and shl error message is missing line numbers

void main()
{
    int c;
    c = c >>> 33;
    c = c >> 33;
    c = c << 33;

    c >>= 33;
    c <<= 33;
    c >>>= 33;
}
