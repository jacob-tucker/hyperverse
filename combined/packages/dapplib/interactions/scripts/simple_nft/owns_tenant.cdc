import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

pub fun main(account: Address): UInt64 {
    return SimpleNFT.getClientTenants()[account]!
}