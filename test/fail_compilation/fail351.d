// Issue 2780 - ref Return Allows modification of immutable data

struct Immutable
{
    immutable uint[2] num;

    ref uint opIndex(uint index) immutable
    {
        return num[index];
    }
}

void main()
{
    immutable Immutable foo;
    //foo[0]++;
}
