import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address): UInt64 {
    let tenant = getAccount(account).getCapability(SimpleFT.getMetadata().tenantPublicPath)
                    .borrow<&SimpleFT.Tenant{IHyperverseComposable.ITenantID}>()
                    ?? panic("Tenant doesn't exist here!")
    return tenant.id
}