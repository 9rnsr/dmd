
enum MyUDC;

struct MyStruct
{
    int a;
    @MyUDC int b;
}

void testAttrs(T)(const ref T t)
if (is(T == struct))
{
    foreach (name; __traits(allMembers, T))
    {
        auto tr = __traits(getAttributes, __traits(getMember, t, name));
    }
}

void main()
{
    MyStruct s;
    testAttrs(s);
}
