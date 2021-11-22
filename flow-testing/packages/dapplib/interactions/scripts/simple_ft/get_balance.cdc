import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantOwner: Address): UFix64 {
    let accountPackage = getAccount(account).getCapability(SimpleToken.BundlePublicPath)
                            .borrow<&SimpleToken.Bundle{SimpleToken.PublicBundle}>()
                            ?? panic("Bundle doesn't exist here!")

    let vault = accountPackage.borrowVaultPublic(tenant: tenantOwner)
    return vault.balance
}