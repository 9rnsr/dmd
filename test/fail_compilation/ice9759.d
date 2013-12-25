/*
TEST_OUTPUT:
---
fail_compilation/ice9759.d(24): Error: function ice9759.Json.opAssign (Json v) is not callable using argument types (const(Json)) const
---
*/

struct Json
{
    union
    {
        Json[] m_array;
        Json[string] m_object;
    }

    void opAssign(Json v)
    {
    }
}

void bug()
{
    const(Json) r;
    r = r.init;
}
