import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): [UInt64] {

    let accountPackage = getAccount(account).getCapability(SimpleNFT.BundlePublicPath)
                                .borrow<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>()!

    return accountPackage.borrowCollectionPublic(tenant: tenantOwner).getIDs()
}