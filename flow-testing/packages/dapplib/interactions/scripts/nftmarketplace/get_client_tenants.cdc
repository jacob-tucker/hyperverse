import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

pub fun main(account: Address): String {
    return NFTMarketplace.getClientTenantID(account: account)!
}