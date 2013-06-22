import imports.test70 : foo;

//alias imports.test70.foo foo; // ICE
void foo(int) // overloads with selective import
{
}

void bar()
{
    //foo();    // doesn't work
}
