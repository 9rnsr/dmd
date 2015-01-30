// REQUIRED_ARGS: -o-
// PERMUTE_ARGS:

/***************************************************/
// 14067 - enum members with stringof

enum E14067 { a }

static assert(E14067.a.stringof == "E14067.a");
enum var14067 = E14067.a;
static assert(var14067.stringof == "E14067.a");

struct S14067(E14067 e) {}
static assert(S14067!(E14067.a).stringof == "S14067!(E14067.a)");
