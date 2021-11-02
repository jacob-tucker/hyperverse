import Rewards from "../../../contracts/Project/Rewards.cdc"

// Map the clientTenant to its alias in SimpleNFT
pub fun main(account: Address): [String] {
    return Rewards.getClientTenants(account: account)
}