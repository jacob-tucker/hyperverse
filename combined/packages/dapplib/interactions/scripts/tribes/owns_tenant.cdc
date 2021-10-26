import Tribes from "../../../contracts/Project/Tribes.cdc"

pub fun main(account: Address): UInt64 {
    return Tribes.getClientTenants()[account]!
}