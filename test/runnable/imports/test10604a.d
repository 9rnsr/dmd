module imports.test10604a;

package int pkgval;

private void foo(){}

private template Foo(int n) { enum Foo = 1; }
public  template Foo(long n) { enum Foo = 2; }

private int bar(int) { return 1; }

mixin template Mix1() { private int baz(int) { return 1; } }
mixin template Mix2() { public  int baz(long) { return 2; } }

mixin Mix1;
mixin Mix2;

class Test
{
    mixin Mix1;
    mixin Mix2;

private:
    static int counter = 0;
}

// Issue 10604 - Not consistent access check for overloaded symbols
version(all)
{
    private template Voo1(T) { enum Voo1 = 1; }
    public  template Voo1(size_t n) { enum Voo1 = 2; }
    public  template Voo2(size_t n) { enum Voo2 = 2; }
    private template Voo2(T) { enum Voo2 = 1; }

    private int voo1(int) { return 1; }
    public  int voo1(string) { return 2; }
    public  int voo2(string) { return 2; }
    private int voo2(int) { return 1; }
}

private template PrivFoo() {}
private template PrivFoo(T) {}
