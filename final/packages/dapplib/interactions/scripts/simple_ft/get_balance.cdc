import SimpleFT from 0x26a365de6d6237cd
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantID: String): UFix64 {

    let accountPackage = getAccount(account).getCapability(SimpleFT.PackagePublicPath)
                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                            ?? panic("Package doesn't exist here!")

    let vault = accountPackage.borrowVaultPublic(tenantID: tenantID)
    return vault.balance
}