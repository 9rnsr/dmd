// REQUIRED_ARGS: -de
/*
TEST_OUTPUT:
---
fail_compilation/depmsg.d(35): Deprecation: struct depmsg.main.Inner.A is deprecated - With message!
fail_compilation/depmsg.d(36): Deprecation: class depmsg.main.Inner.B is deprecated - With message!
fail_compilation/depmsg.d(37): Deprecation: interface depmsg.main.Inner.C is deprecated - With message!
fail_compilation/depmsg.d(38): Deprecation: union depmsg.main.Inner.D is deprecated - With message!
fail_compilation/depmsg.d(39): Deprecation: enum depmsg.main.Inner.E is deprecated - With message!
fail_compilation/depmsg.d(41): Deprecation: alias depmsg.main.Inner.G is deprecated - With message!
fail_compilation/depmsg.d(42): Deprecation: variable depmsg.main.Inner.H is deprecated - With message!
fail_compilation/depmsg.d(43): Deprecation: class depmsg.main.Inner.I!().I is deprecated - With message!
---
*/

void main()
{
    class Inner
    {
        deprecated("With message!")
        {
            struct A { }
            class B { }
            interface C { }
            union D { }
            enum E { e };
            //typedef int F;
            alias int G;
            static int H;
            template I() { class I {} }
        }
    }
    with(Inner)
    {
        A a;
        B b;
        C c;
        D d;
        E e;
        //F f;
        G g;
        auto h = H;
        I!() i;
    }
}
