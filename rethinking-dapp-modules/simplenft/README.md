New shit:

If it's a resource, must have the tenant's id in it (the tenant defined in that contract)
If it's a public function inside the contract and you're passing it a parameter that is the Tenant.IState, just move the function inside the Tenant itself, remove the parameter and expose it in IState.

Tenant creates the minter (gives it its tenantID) -> minter makes the NFTs, checking that the tenant passed in equals its tenantID -> NFT comes out with same id as NFTMinter -> collection also created by tenant. nft and collection must match. conclusion: collections and minters created by same tenant will always match

*There is a core issue here*
- A Vault resource needs to have a Capability to the resource defined in that contract in order to update its state
- There is no way for a capability to be created unless its linked in a public path, which means that Tenant resource is stored on its own. The alternative to this is to have the module higher up implement the IState of the dependency, but this is obviously a problem because then you're importing hundreds of contracts and modules should only have to look 1 layer down.
