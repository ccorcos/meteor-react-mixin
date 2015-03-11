# 0.0.6

Changed `getMeteorSubs` so that you must return a ready function. This cleans up the code a bunch and allows for a cleaner separation of concerns. Its really convenient now to use subs-cache.

# 0.0.5

`getSessionVars` helper.

# 0.0.4

Refactored a lot. `this.subsReady` tells you when all subscriptions are ready. Updated to the state are held off until subscriptions are ready. This prevents unnecessary re-renders while new items are coming in.

Also added InfiniteScroll component with example.


# 0.0.2

Added `this.sessionVar` functionality.