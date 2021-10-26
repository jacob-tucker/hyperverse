import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantOwner: Address): UFix64 {
    let TenantPackage = getAccount(tenantOwner).getCapability(SimpleFT.PackagePublicPath)
                                .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
    let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

    let accountPackage = getAccount(account).getCapability(SimpleFT.PackagePublicPath)
                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                            ?? panic("Package doesn't exist here!")

    let vault = accountPackage.borrowVaultPublic(tenantID: TenantID)
    return vault.balance
}