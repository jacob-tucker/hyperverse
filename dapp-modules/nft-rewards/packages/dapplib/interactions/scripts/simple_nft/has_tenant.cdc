import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address): Bool {
    let tenant = getAccount(account).getCapability(SimpleNFT.getMetadata().tenantPublicPath)
                    .borrow<&SimpleNFT.Tenant{IHyperverseComposable.ITenantID}>()

    if tenant == nil {
        return false
    } else {
        return true
    }
}