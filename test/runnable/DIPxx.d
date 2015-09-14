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

static assert(is(int : U, U if isInt));

/**********************************/

int main()
{
    return 0;
}
