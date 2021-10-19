import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

pub fun main(account: Address, tenantID: UInt64): Bool {
    return SimpleNFT.getTenant(id: tenantID).holder == account
}