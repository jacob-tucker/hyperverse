import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

pub fun main(account: Address, tenantID: UInt64): Bool {
    return NFTMarketplace.getTenant(id: tenantID).holder == account
}