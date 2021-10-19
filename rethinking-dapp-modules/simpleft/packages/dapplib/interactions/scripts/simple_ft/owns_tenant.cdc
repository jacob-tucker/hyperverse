import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantID: UInt64): Bool {
    return SimpleFT.getTenant(id: tenantID).holder == account
}