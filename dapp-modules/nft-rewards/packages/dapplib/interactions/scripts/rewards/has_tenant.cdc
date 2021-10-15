import Rewards from "../../../contracts/Project/Rewards.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address): UInt64 {
    let tenant = getAccount(account).getCapability(Rewards.getMetadata().tenantPublicPath)
                    .borrow<&Rewards.Tenant{IHyperverseComposable.ITenantID}>()
                    ?? panic("Tenant doesn't exist here!")

    return tenant.id
}