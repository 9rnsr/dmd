// REQUIRED_ARGS: -o- -verror

template TypeTuple(T...) { alias TypeTuple = T; }

void main()
{
/+
TEST_OUTPUT:
----
fail_compilation/diag9562.d(32): Error: type float has no value
fail_compilation/diag9562.d(33): Error: type float has no value
fail_compilation/diag9562.d(32): Error: type double has no value
fail_compilation/diag9562.d(33): Error: type double has no value
fail_compilation/diag9562.d(32): Error: type real has no value
fail_compilation/diag9562.d(33): Error: type real has no value
fail_compilation/diag9562.d(32): Error: type ifloat has no value
fail_compilation/diag9562.d(33): Error: type ifloat has no value
fail_compilation/diag9562.d(32): Error: type idouble has no value
fail_compilation/diag9562.d(33): Error: type idouble has no value
fail_compilation/diag9562.d(32): Error: type ireal has no value
fail_compilation/diag9562.d(33): Error: type ireal has no value
fail_compilation/diag9562.d(32): Error: type cfloat has no value
fail_compilation/diag9562.d(33): Error: type cfloat has no value
fail_compilation/diag9562.d(32): Error: type cdouble has no value
fail_compilation/diag9562.d(33): Error: type cdouble has no value
fail_compilation/diag9562.d(32): Error: type creal has no value
fail_compilation/diag9562.d(33): Error: type creal has no value
----
+/
    foreach (F; TypeTuple!(float, double, real, ifloat, idouble, ireal, cfloat, cdouble, creal))
    {
        auto re = F.re;
        auto im = F.im;
    }

/+
TEST_OUTPUT:
----
fail_compilation/diag9562.d(65): Error: type int[1u] has no value
fail_compilation/diag9562.d(68): Error: type int[1u] has no value
fail_compilation/diag9562.d(69): Error: type int[1u] has no value
fail_compilation/diag9562.d(70): Error: type int[1u] has no value
fail_compilation/diag9562.d(71): Error: type int[1u] has no value
fail_compilation/diag9562.d(65): Error: type char[1u] has no value
fail_compilation/diag9562.d(68): Error: type char[1u] has no value
fail_compilation/diag9562.d(69): Error: type char[1u] has no value
fail_compilation/diag9562.d(70): Error: type char[1u] has no value
fail_compilation/diag9562.d(71): Error: type char[1u] has no value
fail_compilation/diag9562.d(65): Error: type int[] has no value
fail_compilation/diag9562.d(67): Error: type int[] has no value
fail_compilation/diag9562.d(68): Error: type int[] has no value
fail_compilation/diag9562.d(69): Error: type int[] has no value
fail_compilation/diag9562.d(70): Error: type int[] has no value
fail_compilation/diag9562.d(71): Error: type int[] has no value
fail_compilation/diag9562.d(65): Error: type char[] has no value
fail_compilation/diag9562.d(67): Error: type char[] has no value
fail_compilation/diag9562.d(68): Error: type char[] has no value
fail_compilation/diag9562.d(69): Error: type char[] has no value
fail_compilation/diag9562.d(70): Error: type char[] has no value
fail_compilation/diag9562.d(71): Error: type char[] has no value
----
+/
    foreach (A; TypeTuple!(int[1], char[1], int[], char[]))
    {
        auto ptr = A.ptr;
      static if (is(A _ : T[], T))
        auto len  = A.length;
        auto rev  = A.reverse;
        auto sort = A.sort;
        auto dup  = A.dup;
        auto idup = A.idup;
    }
}
