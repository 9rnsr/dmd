/*
TEST_OUTPUT:
---
fail_compilation/fail15069.d(11): Error: template instance T!int T is not a template declaration, it is a struct
fail_compilation/fail15069.d(21): Error: template instance fail15069.Stuff!(Thing!float) error instantiating
---
*/

struct Stuff(T)
{
    T!int var;
}

struct Thing(T)
{
    T varling;
}

void main()
{
    Stuff!(Thing!float) stuff;
}

// from runnable/template9.d
/*
TEST_OUTPUT:
---
fail_compilation/fail15069.d(40): Error: template instance T!int T is not a template declaration, it is a class
fail_compilation/fail15069.d(43): Error: template instance fail15069.Templ5988!(C5988a!int) error instantiating
fail_compilation/fail15069.d(50):        instantiated from here: C5988a!int
fail_compilation/fail15069.d(40): Error: template instance T!int T is not a template declaration, it is a class
fail_compilation/fail15069.d(45): Error: template instance fail15069.Templ5988!(T!int) error instantiating
fail_compilation/fail15069.d(40):        instantiated from here: T!int
fail_compilation/fail15069.d(52):        instantiated from here: Templ5988!(C5988b)
---
*/

template Templ5988(alias T)
{
    alias T!int Templ5988;
}

class C5988a(T) { Templ5988!C5988a foo; }

class C5988b(T) { Templ5988!C5988b foo; }

void fail5988()
{
    //Templ5988!C5988a foo5988a;        // Commented version
    C5988a!int c5988a;

    Templ5988!C5988b foo5988b;          // Uncomment version
    C5988b!int c5988b;
}
