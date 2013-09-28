/*
TEST_OUTPUT:
---
fail_compilation/fail252.d(15): Error: 'this' is only defined in non-static member functions, not Timer
fail_compilation/fail252.d(15): Error: 'this' for nested class must be a class type, not _error_
---
*/

class Timer
{
    abstract class Task
    {
        public abstract void run();
    }
    private Task IDLE = new class() Task
    {
        int d;
        public override void run()
        {
        }
    };
}
