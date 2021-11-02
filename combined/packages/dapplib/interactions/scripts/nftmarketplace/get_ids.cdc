import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

pub fun main(account: Address, tenantOwner: Address): [UInt64] {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(NFTMarketplace.getType().identifier)

    let accountPackage = getAccount(account).getCapability(NFTMarketplace.PackagePublicPath)
                            .borrow<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>()
                            ?? panic("Could not borrow the public NFTMarketplace Package from account.")
    
    return accountPackage.borrowSaleCollectionPublic(tenantID: tenantID).getIDs()
}