import Tribes from "../../../contracts/Project/Tribes.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): String {
    let TenantPackage = getAccount(tenantOwner).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
    let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

    let accountPackage = getAccount(account).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()!

    let tribe = accountPackage.borrowIdentityPublic(tenantID: TenantID).currentTribeName

    if tribe == nil {
        return "None!"
    } else {
        return tribe!
    }
}