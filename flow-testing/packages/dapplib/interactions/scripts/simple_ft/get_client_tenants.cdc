import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

pub fun main(account: Address): String {
    return SimpleToken.getClientTenantID(account: account)!
}