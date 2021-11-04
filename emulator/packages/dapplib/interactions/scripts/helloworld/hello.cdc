import HelloWorld from "../../../contracts/Project/HelloWorld.cdc"

pub fun main(tenantOwner: Address): String {
    if let tenantID = HelloWorld.getClientTenantID(account: tenantOwner) {
        return "Hello, World!"
    } else {
        return "This account does not own a Tenant."
    }
}