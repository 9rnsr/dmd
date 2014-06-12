
version(D_Version2)
{
    enum int a = .b;
    enum int b = a;
}
else
{
    const int a = .b;
    const int b = .a;
}
enum int bug7209 = bug7209;
