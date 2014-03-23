void main()
{
    import core.stdc.stdio;

    static assert(core.stringof == "package core");
    static assert(core.stdc.stringof == "package stdc");
    static assert(core.stdc.stdio.stringof == "module stdio");

    printf("");
    core.stdc.stdio.printf("");
}
