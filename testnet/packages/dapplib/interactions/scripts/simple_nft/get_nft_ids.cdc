import SimpleNFT from 0x26a365de6d6237cd

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantID: String): [UInt64] {

    let accountPackage = getAccount(account).getCapability(SimpleNFT.PackagePublicPath)
                                .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()!

    return accountPackage.borrowCollectionPublic(tenantID: tenantID).getIDs()
}