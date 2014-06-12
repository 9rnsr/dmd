
import imports.a11919;

enum foo;

class Foo
{
    @foo bool _foo;
}

class Bar : Foo {}

void main()
{
    auto bar = new Bar();
    bar.doBar;
}
