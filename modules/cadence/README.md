You need a Package for a contract. You only need to get this Package one time. Whether it's a dependency, the main module, doesn't matter, you need  to get it one time.

Any time you have a pub function inside of a contract, that needs to take in a Tenant{IState} to modify the state, just move it into the Tenant itself, remove that parameter and make it public exposable inside IState.