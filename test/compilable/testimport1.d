import core.stdc.stdio;
static import core.stdc.ctype : isalnum;
static import core.stdc.ctype : isspace;

void main()
{
    static assert(core.stringof == "package core");
    static assert(core.stdc.stringof == "package stdc");
    static assert(core.stdc.stdio.stringof == "module stdio");

    printf("");
    core.stdc.stdio.printf("");

    static assert(!__traits(compiles, isalnum('a')));
    core.stdc.ctype.isalnum('a');
    static assert(!__traits(compiles, core.stdc.ctype.isalpha('a')));
    core.stdc.ctype.isspace(' ');
}
