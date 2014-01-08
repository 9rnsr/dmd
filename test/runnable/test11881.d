// REQUIRED_ARGS: -defaultlib= -betterC

extern(C) int printf(const char*, ...);

struct S
{
    void foo()
    {
        printf("call S.foo, &this = %p\n", &this);
    }
}

extern(C) int main(int argc, char** argv)
{
    S s;
    s.foo();

    return 0;
}
