// REQUIRED_ARGS: -o-
// PERMUTE_ARGS:
/*
TEST_OUTPUT:
---
compilable/testdeprecate.d(15): Deprecation: struct testdeprecate.DS is deprecated
compilable/testdeprecate.d(16): Deprecation: struct testdeprecate.DS is deprecated
compilable/testdeprecate.d(18): Deprecation: struct testdeprecate.DS is deprecated
compilable/testdeprecate.d(20): Deprecation: struct testdeprecate.DS is deprecated
---
*/

deprecated struct DS {}

DS ds1;
auto ds2 = DS();

DS makeDS()         // this function already have deprecated type name in its signature, so
{
    return DS();    // one more deprecation message in here is necessary?
}
auto ds3 = makeDS();
