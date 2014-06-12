// REQUIRED_ARGS: -m64

// Issue 581 - Error message w/o line number in dot-instantiated template

template X(){}

template D(string str){}

template A(string str)
{
    static if (D!(str[str]))
    {}
    else
        const string A = .X!();
}

template M(alias B)
{
    const string M = A!("a");
}

void main()
{
    int q = 3;
    pragma(msg, M!(q));
}
