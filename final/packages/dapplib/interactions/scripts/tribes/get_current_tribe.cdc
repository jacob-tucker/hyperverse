import Tribes from 0x26a365de6d6237cd

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantID: String): String {

    let accountPackage = getAccount(account).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()!

    let tribe = accountPackage.borrowIdentityPublic(tenantID: tenantID).currentTribeName

    if tribe == nil {
        return "None!"
    } else {
        return tribe!
    }
}