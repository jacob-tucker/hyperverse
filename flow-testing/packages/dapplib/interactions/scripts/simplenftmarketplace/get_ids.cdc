import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

pub fun main(account: Address, tenantOwner: Address): [UInt64] {
    let accountPackage = getAccount(account).getCapability(SimpleNFTMarketplace.BundlePublicPath)
                            .borrow<&SimpleNFTMarketplace.Bundle{SimpleNFTMarketplace.PublicBundle}>()
                            ?? panic("Could not borrow the public SimpleNFTMarketplace Bundle from account.")
    
    return accountPackage.borrowSaleCollectionPublic(tenant: tenantOwner).getIDs()
}