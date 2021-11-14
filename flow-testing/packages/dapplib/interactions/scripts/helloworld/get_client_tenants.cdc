import HelloWorld from "../../../contracts/Project/HelloWorld.cdc"

pub fun main(account: Address): String {
    return HelloWorld.getClientTenantID(account: account)!
}