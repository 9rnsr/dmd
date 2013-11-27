/*
TEST_OUTPUT:
---
fail_compilation/fail16.d(20): Error: function declaration without return type. (Note that constructors are always named 'this')
fail_compilation/fail16.d(20): Error: no identifier for declarator bar!(typeof(X))(X)
---
*/

// ICE(template.c) in DMD0.080

int i;

template bar(T)
{
  void bar(int x) {}
}

template foo(alias X)
{
  bar!(typeof(X))(X);
}


void main()
{
  foo!(i);
}

