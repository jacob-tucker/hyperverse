You need a Package for a contract. You only need to get this Package one time. Whether it's a dependency, the main module, doesn't matter, you need  to get it one time.

Any time you have a pub function inside of a contract, that needs to take in a Tenant{IState} to modify the state, just move it into the Tenant itself, remove that parameter and make it public exposable inside IState.

Resources need a tenantID inside of them.

Resources that should be stored by an account (like an NFTMinter, Identity, Collection) should all be moved inside the Package. The current idea is the functions inside Package should take in the resources themselves, then have borrow functions that expose the full reference, and then potentially other functions that expose the public versions of those references and then expose those functions inside PackagePublic (see SimpleNFT)