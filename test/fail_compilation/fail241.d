/*
TEST_OUTPUT:
---
fail_compilation/fail241.d(16): Error: function fail241.Foo.f () is not callable using argument types () const
fail_compilation/fail241.d(17): Error: function fail241.Foo.g () is not callable using argument types () const
---
*/

class Foo
{
    public void f() { }
    private void g() { }

    invariant()
    {
        f();  // error, cannot call public member function from invariant
        g();  // ok, g() is not public
    }
}
