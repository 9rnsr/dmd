void foo1() {}
void foo1(int) {}

void foo2()() {}
void foo2(int) {}

void foo3() {}
void foo3()(int) {}

void foo4()() {}
void foo4(T)(T) if (is(T == int)) {}

void foo5()() {}

void main()
{
    foo1(1.0);
    foo2(1.0);
    foo3(1.0);
    foo4(1.0);
    foo5(1.0);
}
