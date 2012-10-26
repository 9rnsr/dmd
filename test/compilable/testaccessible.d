
/***************************************************/

import imports.bug4731;

class Super4731 : Base4731
{
    void bar() { super.foo(); }     // works
    void baz() { Base4731.foo(); }  // does not work:
    //Error: class Foo.Base member foo is not accessible
}

/***************************************************/
