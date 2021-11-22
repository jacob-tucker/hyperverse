import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

pub fun main(account: Address, tenantOwner: Address): [UInt64] {
    let accountPackage = getAccount(account).getCapability(NFTMarketplace.BundlePublicPath)
                            .borrow<&NFTMarketplace.Bundle{NFTMarketplace.PublicBundle}>()
                            ?? panic("Could not borrow the public NFTMarketplace Bundle from account.")
    
    return accountPackage.borrowSaleCollectionPublic(tenant: tenantOwner).getIDs()
}