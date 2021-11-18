import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"

pub fun main(account: Address): String {
    return SimpleNFTMarketplace.clientTenantID(account: account)
}