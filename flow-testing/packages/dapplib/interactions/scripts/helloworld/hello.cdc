import HelloWorld from "../../../contracts/Project/HelloWorld.cdc"

pub fun main(tenantOwner: Address): String {
    return HelloWorld.getTenant(account: tenantOwner).greeting
}