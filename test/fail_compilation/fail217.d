/*
TEST_OUTPUT:
---
fail_compilation/fail217.d(21): Error: can only initialize const member notifier inside constructor
---
*/

class Message
{
    public int notifier;

    this(int notifier_object) immutable
    {
        notifier = notifier_object;
    }
}

void main()
{
    auto m2 = new immutable(Message)(2);
    m2.notifier = 3;
}
