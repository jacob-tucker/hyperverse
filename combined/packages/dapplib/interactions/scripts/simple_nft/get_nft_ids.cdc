import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): [UInt64] {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleNFT.getType().identifier)
                        .concat(".0")

    let accountPackage = getAccount(account).getCapability(SimpleNFT.PackagePublicPath)
                                .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()!

    return accountPackage.borrowCollectionPublic(tenantID: tenantID).getIDs()
}