import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

pub fun main(account: Address): UInt64 {
    return NFTMarketplace.getClientTenants()[account]!
}