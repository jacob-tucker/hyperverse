import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenant: Address): [UInt64] {
    let tenant = getAccount(tenant).getCapability(SimpleNFT.getMetadata().tenantPublicPath)
                    .borrow<&SimpleNFT.Tenant{SimpleNFT.IState}>()
                    ?? panic("Could not borrow the tenant.")

    let accountPackage = getAccount(account).getCapability(SimpleNFT.PackagePublicPath)
                                .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()!

    return accountPackage.borrowCollectionPublic(tenantID: tenant.id).getIDs()
}