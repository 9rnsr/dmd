/*
TEST_OUTPUT:
---
fail_compilation/ice11553.d(23): Error: recursive template expansion while looking for A!().A()
fail_compilation/ice11553.d(23):        instantiated from here: ice11553.A!(B).A!()()
fail_compilation/ice11553.d(23):        instantiated from here: ice11553.A!(B).A!()()
---
*/

template A(alias T)
{
    template A()
    {
        alias A = T!();
    }
}

template B()
{
    alias B = A!(.B);
}

static if (A!B) {}
