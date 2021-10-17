import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenant: Address): UFix64 {
    let tenant = getAccount(tenant).getCapability(SimpleFT.getMetadata().tenantPublicPath)
                    .borrow<&SimpleFT.Tenant{IHyperverseComposable.ITenantID}>()
                    ?? panic("Tenant doesn't exist here!")

    let accountPackage = getAccount(account).getCapability(SimpleFT.PackagePublicPath)
                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                            ?? panic("Package doesn't exist here!")

    let vault = accountPackage.borrowVaultPublic(tenantID: tenant.id)
    return vault.balance
}