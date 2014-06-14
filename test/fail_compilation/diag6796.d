/*
TEST_OUTPUT:
---
fail_compilation/diag6796.d(10): Error: cannot implicitly convert expression ([0, 1]) of type int[] to int[][]
---
*/

void main()
{
    enum int[][] array = [0, 1];
    array[0] *= 10;
}
