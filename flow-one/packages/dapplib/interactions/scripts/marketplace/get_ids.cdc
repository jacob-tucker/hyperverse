import Marketplace from "../../../contracts/Project/Marketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

pub fun main(account: Address, tenantOwner: Address): [UInt64] {
    let accountCollection = getAccount(account).getCapability(SimpleNFT.CollectionPublicPath)
                                .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()
                                ?? panic("Could not borrow the SimpleNFT Collection.")
    
    return accountCollection.getIDs(tenantOwner)
}