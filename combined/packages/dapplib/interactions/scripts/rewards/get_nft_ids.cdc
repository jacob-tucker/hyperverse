import Rewards from "../../../contracts/Project/Rewards.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): [UInt64] {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(Rewards.getType().identifier)
                        .concat(".0")

    let accountPackage = getAccount(account).getCapability(Rewards.PackagePublicPath)
                                .borrow<&Rewards.Package{Rewards.PackagePublic}>()!

    return accountPackage.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: tenantID).getIDs()
}