/*
TEST_OUTPUT:
---
fail_compilation/fail204.d(19): Error: shift by 65 is outside the range 0..63
fail_compilation/fail204.d(19): Error: shift by 65 is outside the range 0..63
fail_compilation/fail204.d(20): Error: shift by 65 is outside the range 0..63
fail_compilation/fail204.d(20): Error: shift by 65 is outside the range 0..63
fail_compilation/fail204.d(21): Error: shift by 65 is outside the range 0..63
fail_compilation/fail204.d(21): Error: shift by 65 is outside the range 0..63
fail_compilation/fail204.d(23): Error: shift assign by 65 is outside the range 0..63
fail_compilation/fail204.d(24): Error: shift assign by 65 is outside the range 0..63
fail_compilation/fail204.d(25): Error: shift assign by 65 is outside the range 0..63
---
*/

void main()
{
    long c;
    c = c >>> 65;
    c = c >> 65;
    c = c << 65;

    c >>= 65;
    c <<= 65;
    c >>>= 65;
}
