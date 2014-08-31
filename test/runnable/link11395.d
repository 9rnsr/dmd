// extra_sources: imports/link11395a.d
// PERMUTE_ARGS:
// compile_separately
/+
module link11395;
import imports.link11395a;

void main()
{
    SB s;
    SB[] a;

    a ~= s;
}
+/

void main() {}