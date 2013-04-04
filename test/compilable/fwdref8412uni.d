// REQUIRED_ARGS: -o-
// PERMUTE_ARGS:
module fwdref8412uni;

import imports.fwdref8412uni_tab;

template BasicSetOps() {}
struct RleBitSet(T) { mixin BasicSetOps; }
