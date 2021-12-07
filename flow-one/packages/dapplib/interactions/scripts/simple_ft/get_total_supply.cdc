import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(tenantOwner: Address): UFix64 {
    return SimpleToken.getTotalSupply(tenant: tenantOwner)
}