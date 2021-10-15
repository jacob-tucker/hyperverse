What I've essentially done here is the exact same thing as the normal way, except it includes collections to deal with storage path problems.

The main Tenant gets put into its collection defined in the same contract (the dependencies of the Tenant tag along), and when you need to get the ITenantState, you call the function inside the collection.