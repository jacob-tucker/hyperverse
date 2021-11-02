import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

pub fun main(account: Address): String {
    return SimpleFT.getClientTenantID(account: account)!
}