// PERMUTE_ARGS:
// REQUIRED_ARGS: -D -Dd${RESULTS_DIR}/compilable -o-
// POST_SCRIPT: compilable/extra-files/ddocAny-postscript.sh 14067

module ddoc14067;

///
enum E { a }

void fun(E e)() {}

///
alias FA = fun!(E.a);

struct S(E e) {}

///
alias SA = S!(E.a);
