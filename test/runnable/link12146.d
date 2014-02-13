// COMPILE_SEPARATELY: -g
// EXTRA_SOURCES: imports/link12146a.d

import imports.link12146a;

struct Appender
{
    Bar[] tokens;
    // implicitly generated
    //   bool opEquals(const ref Appender rhs) const
    // will make
    //   tokens == rhs.tokens
    // references TypeInfo of Bar
    // and it references __xopCmp
}

void main() {}
