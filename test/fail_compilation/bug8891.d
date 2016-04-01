/*
TEST_OUTPUT:
---
fail_compilation/bug8891.d(21): Error: 'this' is only defined in non-static member functions, not main
---
*/

struct S
{
    int value = 10;
    S opCall(int n) // non-static
    {
        //printf("this.value = %d\n", this.value);    // prints garbage!
        S s;
        s.value = n;
        return s;
    }
}
void main()
{
    S s = 10;
}
