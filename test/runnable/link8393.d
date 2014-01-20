// REQUIRED_ARGS: -g

template isAllocator(A)
{
    enum bool isAllocator = is(typeof({
        A a;
        static class C {}
        C c = a.create!C; // <- comment out and no undefined references
    }));
}
struct GCAllocator
{
    C create(C)()
    {
        return new C;
    }
}

pragma(msg,isAllocator!GCAllocator);

void main() {}
