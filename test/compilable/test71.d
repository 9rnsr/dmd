import imports.test71;

void bar()
{
    //imports.test71.foo(); // OK -> NG
    //imports_test71.foo(); // -> NG
    imports.imports_test71.foo();   // -> OK
}
