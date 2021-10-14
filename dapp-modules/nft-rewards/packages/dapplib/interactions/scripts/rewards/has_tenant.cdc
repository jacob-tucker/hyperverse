import Rewards from "../../../contracts/Project/Rewards.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address): Bool {
    let tenant = getAccount(account).getCapability(Rewards.getMetadata().tenantPublicPath)
                    .borrow<&Rewards.Tenant{IHyperverseComposable.ITenantID}>()

    if tenant == nil {
        return false
    } else {
        return true
    }
}