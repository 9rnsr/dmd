// REQUIRED_ARGS: -o-
// PERMUTE_ARGS:
module fwdref8412uni;

import imports.fwdref8412traits;

template BasicSetOps() {}
struct RleBitSet(T) { mixin BasicSetOps; }
