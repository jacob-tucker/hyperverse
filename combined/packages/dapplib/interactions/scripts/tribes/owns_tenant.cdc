import Tribes from "../../../contracts/Project/Tribes.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantID: UInt64): Bool {
    return Tribes.getTenant(id: tenantID).holder == account
}