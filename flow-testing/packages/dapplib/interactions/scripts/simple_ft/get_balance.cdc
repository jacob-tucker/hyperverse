import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantOwner: Address): UFix64 {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleToken.getType().identifier)

    let accountPackage = getAccount(account).getCapability(SimpleToken.PackagePublicPath)
                            .borrow<&SimpleToken.Package{SimpleToken.PackagePublic}>()
                            ?? panic("Package doesn't exist here!")

    let vault = accountPackage.borrowVaultPublic(tenantID: tenantID)
    return vault.balance
}