// REQUIRED_ARGS: -o-
// PERMUTE_ARGS:

/***************************************************/
// 1748 class template with stringof

struct S1748(T) {}
static assert(S1748!int.stringof == "S1748!int");

class C1748(T) {}
static assert(C1748!int.stringof == "C1748!int");

/***************************************************/
// 14067 - enum members with stringof

enum E14067 { a }

static assert(E14067.a.stringof == "E14067.a");
enum var14067 = E14067.a;
static assert(var14067.stringof == "E14067.a");

struct S14067(E14067 e) {}
static assert(S14067!(E14067.a).stringof == "S14067!(E14067.a)");
