import HelloWorld from "../../../contracts/Project/HelloWorld.cdc"

pub fun main(tenantOwner: Address): String {
    return HelloWorld.getGreeting(tenantOwner)
}