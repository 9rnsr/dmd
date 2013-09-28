// PERMUTE_ARGS: -dw
/*
TEST_OUTPUT:
---
fail_compilation/fail243a.d(29): Deprecation: use of typedef is deprecated; use alias instead
fail_compilation/fail243a.d(29): Deprecation: use of typedef is deprecated; use alias instead
fail_compilation/fail243a.d(32): Deprecation: class fail243a.DepClass is deprecated
fail_compilation/fail243a.d(33): Deprecation: struct fail243a.DepStruct is deprecated
fail_compilation/fail243a.d(34): Deprecation: union fail243a.DepUnion is deprecated
fail_compilation/fail243a.d(35): Deprecation: enum fail243a.DepEnum is deprecated
fail_compilation/fail243a.d(36): Deprecation: alias fail243a.DepAlias is deprecated
fail_compilation/fail243a.d(37): Deprecation: typedef fail243a.DepTypedef is deprecated
fail_compilation/fail243a.d(32): Deprecation: class fail243a.DepClass is deprecated
fail_compilation/fail243a.d(33): Deprecation: struct fail243a.DepStruct is deprecated
fail_compilation/fail243a.d(34): Deprecation: union fail243a.DepUnion is deprecated
fail_compilation/fail243a.d(35): Deprecation: enum fail243a.DepEnum is deprecated
fail_compilation/fail243a.d(37): Deprecation: typedef fail243a.DepTypedef is deprecated
fail_compilation/fail243a.d(40): Error: static assert  (0) is false
---
*/

deprecated
{
    class DepClass {}
    struct DepStruct {}
    union DepUnion {}
    enum DepEnum { A }
    alias int DepAlias;
    typedef int DepTypedef;
}

void func(DepClass obj) {}
void func(DepStruct obj) {}
void func(DepUnion obj) {}
void func(DepEnum obj) {}
void func(DepAlias obj) {}
void func(DepTypedef obj) {}

// Progress compilation until semantic3() done
void main() { static assert(0); }
