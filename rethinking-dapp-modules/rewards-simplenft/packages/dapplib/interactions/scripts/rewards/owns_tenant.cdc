import Rewards from "../../../contracts/Project/Rewards.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantID: UInt64): Bool {
    return Rewards.getTenant(id: tenantID).holder == account
}