alias void FuncType();

struct Opaque;

template Tuple(T...) { alias T Tuple; }
alias Tuple!(int, int) TupleType;

/******************************************/
// return type

/*
TEST_OUTPUT:
---
fail_compilation/fail12436.d(18): Error: functions cannot return a function
fail_compilation/fail12436.d(19): Error: functions cannot return a tuple
---
*/
FuncType test1();
TupleType test2();

/*
TEST_OUTPUT:
---
fail_compilation/fail12436.d(28): Error: functions cannot return opaque type Opaque by value
fail_compilation/fail12436.d(29): Error: functions cannot return opaque type Opaque[1] by value
---
*/
Opaque    ret12436a();  // error
Opaque[1] ret12436b();  // error
Opaque*   ret12436c();  // no error
Opaque[]  ret12436d();  // no error
Opaque[]* ret12436e();  // no error

ref Opaque    ret12436f();  // no error
ref Opaque[1] ret12436g();  // no error

/******************************************/
// parameter type

/*
TEST_OUTPUT:
---
fail_compilation/fail12436.d(46): Error: cannot have parameter of function type void()
---
*/
void test3(FuncType) {}

/*
TEST_OUTPUT:
---
fail_compilation/fail12436.d(55): Error: cannot have parameter of opaque type Opaque by value
fail_compilation/fail12436.d(56): Error: cannot have parameter of opaque type Opaque[1] by value
---
*/
void param12436a(Opaque);     // error
void param12436b(Opaque[1]);  // error
void param12436c(Opaque*);    // no error
void param12436d(Opaque[]);   // no error
void param12436e(Opaque[]*);  // no error

void param12436f(ref Opaque);     // no error
void param12436g(ref Opaque[1]);  // no error
void param12436h(out Opaque);     // no error
void param12436i(out Opaque[1]);  // no error

/*
TEST_OUTPUT:
---
fail_compilation/fail12436.d(75): Error: cannot have parameter of opaque type A14906 by value
fail_compilation/fail12436.d(76): Error: cannot have parameter of opaque type A14906[3] by value
fail_compilation/fail12436.d(77): Error: cannot have parameter of opaque type A14906[3][3] by value
---
*/
enum A14906;
void f14906a(A14906) {}
void f14906b(A14906[3]) {}
void f14906c(A14906[3][3]) {}

/*
TEST_OUTPUT:
---
fail_compilation/fail12436.d(93): Error: variable fail12436.ev1 cannot be declared with opaque type E
fail_compilation/fail12436.d(94): Error: variable fail12436.ev2 cannot be declared with opaque type E[3]
fail_compilation/fail12436.d(95): Error: variable fail12436.ev3 cannot be declared with opaque type E[3][3]
fail_compilation/fail12436.d(97): Error: variable fail12436.sv1 cannot be declared with opaque type S
fail_compilation/fail12436.d(98): Error: variable fail12436.sv2 cannot be declared with opaque type S[3]
fail_compilation/fail12436.d(99): Error: variable fail12436.sv3 cannot be declared with opaque type S[3][3]
---
*/
enum E;
struct S;

E ev1;
E[3] ev2;
E[3][3] ev3;

S sv1;
S[3] sv2;
S[3][3] sv3;
