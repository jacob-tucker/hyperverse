import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

pub fun main(account: Address): UInt64 {
    return SimpleFT.getClientTenants()[account]!
}