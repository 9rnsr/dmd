// PERMUTE_ARGS:

extern(C) int printf(const char*, ...);

/*******************************************************/
// NVI - 4542?

interface Transmogrifier
{
    final void thereAndBack() {
        transmogrify();
        untransmogrify();
    }
private:
    void transmogrify();
    void untransmogrify();
}

//version(none)
class CardboardBox : Transmogrifier
{
    int count;
    override private void transmogrify() { count += 1; }
    override private void untransmogrify() { count += 10; }
}

void test4542()
{
    auto cbb = new CardboardBox();
    cbb.thereAndBack();
    assert(cbb.count == 11);
}

/*******************************************************/

int main()
{
    test4542();

    printf("Success\n");
    return 0;
}
