// REQUIRED_ARGS: -o-
// PERMUTE_ARGS:

// Tests for Statement::blockExit, Expression:canThrow, etc

/**********************************/
// 7910

int func7910()
out(result)
{
    assert(result == 3);
}
body
{
    while (true)
    {
        return 3;
    }
}

void test7910()
{
    func7910();
}
