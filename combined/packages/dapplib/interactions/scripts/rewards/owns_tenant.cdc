import Rewards from "../../../contracts/Project/Rewards.cdc"

pub fun main(account: Address): UInt64 {
    return Rewards.getClientTenants()[account]!
}