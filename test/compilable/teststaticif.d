
/***************************************************/
// XXXX

/* Test for StaticIfDeclaration with true condition
 */
alias void function() BugXXXXF1;
static if (is(BugXXXXF1 BugXXXXR1 : BugXXXXR1*) &&
           is(BugXXXXR1 == function))
{
    pragma(msg, BugXXXXR1);
    static assert(is(BugXXXXR1 == function));
    alias BugXXXXR1 BugXXXXR1T;
}
else
{
    static assert(false);
    alias int BugXXXXR1F;
}
static assert(!is(BugXXXXR1));
static assert( is(BugXXXXR1T == function));
static assert(!is(BugXXXXR1F));


/* Test for StaticIfDeclaration with false condition
 */
alias void function(int) BugXXXXF2;
static if ( is(BugXXXXF2 BugXXXXR2 : BugXXXXR2*) &&
           !is(BugXXXXR2 == function))
{
    static assert(false);
    alias int BugXXXXR2T;
}
else
{
    static assert(!is(BugXXXXR2));
    alias int BugXXXXR2F;
}
static assert(!is(BugXXXXR2));
static assert(!is(BugXXXXR2T));
static assert( is(BugXXXXR2F == int));


void testXXXX()
{
    /* Test for ConditionalStatement + StaticIfCondition with true condition
     */
    alias void function() BugXXXXF3;
    static if (is(BugXXXXF3 BugXXXXR3 : BugXXXXR3*) &&
               is(BugXXXXR3 == function))
    {
        pragma(msg, BugXXXXR3);
        static assert(is(BugXXXXR3 == function));
        alias BugXXXXR3 BugXXXXR3T;
    }
    else
    {
        static assert(false);
        alias int BugXXXXR3F;
    }
    static assert(!is(BugXXXXR3));
    static assert( is(BugXXXXR3T == function));
    static assert(!is(BugXXXXR3F));


    /* Test for ConditionalStatement + StaticIfCondition with false condition
     */
    alias void function(int) BugXXXXF4;
    static if ( is(BugXXXXF4 BugXXXXR4 : BugXXXXR4*) &&
               !is(BugXXXXR4 == function))
    {
        static assert(false);
        alias int BugXXXXR4T;
    }
    else
    {
        static assert(!is(BugXXXXR4));
        alias int BugXXXXR4F;
    }
    static assert(!is(BugXXXXR4));
    static assert(!is(BugXXXXR4T));
    static assert( is(BugXXXXR4F == int));
}
