import Tribes from "../../../contracts/Project/Tribes.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): String {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(Tribes.getType().identifier)
                        .concat(".0")
                        
    let accountPackage = getAccount(account).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()!

    let tribe = accountPackage.borrowIdentityPublic(tenantID: tenantID).currentTribeName

    if tribe == nil {
        return "None!"
    } else {
        return tribe!
    }
}