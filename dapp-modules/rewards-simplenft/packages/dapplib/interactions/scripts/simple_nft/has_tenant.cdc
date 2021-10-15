import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address): UInt64 {
    let tenant = getAccount(account).getCapability(SimpleNFT.getMetadata().tenantPublicPath)
                    .borrow<&SimpleNFT.Tenant{IHyperverseComposable.ITenantID}>()
                    ?? panic("Tenant doesn't exist here!")
    return tenant.id
}