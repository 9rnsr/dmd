// PERMUTE_ARGS:

alias TypeTuple(T...) = T;

/**********************************/

enum bool isInt(T) = is(T == int);

enum bool isIntType(alias a) = is(typeof(a) == int);
int intValue;
long longValue;

enum bool isMoreThanTwo(alias v) = v > 2;

template isSetOf(A...) if (A.length == 2)
{
    enum bool isSetOf(T...) =
        is(T == TypeTuple!(A[0], A[1])) ||
        is(T == TypeTuple!(A[1], A[0]));
}

// ----

template FooType(T if isInt) {}
static assert( __traits(compiles, FooType!int));
static assert(!__traits(compiles, FooType!long));

template FooAlias(alias A if isIntType) {}
static assert( __traits(compiles, FooAlias!intValue));
static assert(!__traits(compiles, FooAlias!longValue));

template FooValue(int T if isMoreThanTwo) {}
static assert( __traits(compiles, FooValue!5));
static assert(!__traits(compiles, FooValue!2));

template FooTuple(T... if isSetOf!(int, string)) {}
static assert( __traits(compiles, FooTuple!(int,  string)));
static assert( __traits(compiles, FooTuple!(string,  int)));
static assert(!__traits(compiles, FooTuple!(int,    long)));
static assert(!__traits(compiles, FooTuple!(long, string)));

// ----

template FooType2(isInt T) {}
static assert( __traits(compiles, FooType2!int));
static assert(!__traits(compiles, FooType2!long));

template FooTuple2(isSetOf!(int, string) T...) {}
static assert( __traits(compiles, FooTuple2!(int,  string)));
static assert( __traits(compiles, FooTuple2!(string,  int)));
static assert(!__traits(compiles, FooTuple2!(int,    long)));
static assert(!__traits(compiles, FooTuple2!(long, string)));

// ----

static assert(is(int : U, U if isInt));
static assert(is(int : U, isInt U));

/**********************************/
// 15027

@property bool empty(T)(T[] a) { return a.length == 0; }
@property ref T front(T)(T[] a) { return a[0]; }
void popFront(T)(ref T[] a) { a = a[1..$]; }

@property T[] save(T)(T[] a) { return a; }

@property ref T back(T)(T[] a) { return a[$ - 1]; }

enum bool InputRange(R) =
is(typeof((ref R r)
{
    if (r.empty) {}
    auto h = r.front;
    r.popFront();
}));


enum bool ForwardRange(InputRange R) =
is(typeof((ref R r)
{
    static assert(is(typeof({ return r.save; }()) == R));
}));

enum bool isBidirectionalRange(ForwardRange R) =
is(typeof((ref R r)
{
    r.popBack();
    static assert(is( typeof({ return r.back; }()) ==
                      typeof({ return r.front; }()) ));
}));

// ----

struct DirEntry15027
{
    @property string name() { return ""; }
    alias name this;
}

bool isDir15027(InputRange R)(R r) { return true; }

void test15027()
{
    DirEntry15027 de;
    bool c = isDir15027(de);
}

// ----

auto foo15027(ForwardRange R)(R r) { return 1; }
auto foo15027(  InputRange R)(R r) { return 2; }

struct MyRange15027
{
    int[] a;
    @property empty() { return a.empty; }
    @property front() { return a.front; }
    void popFront() { return a.popFront(); }
    @disable void save();
}

void test15027a()
{
    MyRange15027 r;
    assert(foo15027(r) == 2);
}

/**********************************/

int main()
{
    test15027();
    test15027a();

    return 0;
}
