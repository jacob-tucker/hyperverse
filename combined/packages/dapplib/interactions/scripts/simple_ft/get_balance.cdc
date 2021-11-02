import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantOwner: Address): UFix64 {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleFT.getType().identifier)

    let accountPackage = getAccount(account).getCapability(SimpleFT.PackagePublicPath)
                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                            ?? panic("Package doesn't exist here!")

    let vault = accountPackage.borrowVaultPublic(tenantID: tenantID)
    return vault.balance
}