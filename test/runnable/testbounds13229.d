// EXTRA_SOURCES: imports/a13229.d

import imports.a13229;
import core.exception : RangeError;

void main()
{
    try
    {
        fun(2);
    }
    catch (RangeError e)
    {
        assert(e.file[$-8..$] == "a13229.d");
        assert(e.line == 6);
    }

    mixin Mix1324;
    test1324(1);
}
