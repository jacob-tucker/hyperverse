import Tribes from "../../../contracts/Project/Tribes.cdc"

pub fun main(account: Address): [String] {
    return Tribes.getClientTenants(account: account)
}