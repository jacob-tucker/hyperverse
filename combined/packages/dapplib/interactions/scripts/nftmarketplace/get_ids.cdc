import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

pub fun main(account: Address, tenantID: String): [UInt64] {

    let accountPackage = getAccount(account).getCapability(NFTMarketplace.PackagePublicPath)
                            .borrow<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>()
                            ?? panic("Could not borrow the public NFTMarketplace Package from account.")
    
    return accountPackage.borrowSaleCollectionPublic(tenantID: tenantID).getIDs()
}