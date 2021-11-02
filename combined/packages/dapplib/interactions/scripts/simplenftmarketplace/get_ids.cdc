import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"

pub fun main(account: Address, tenantOwner: Address): [UInt64] {

    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleNFTMarketplace.getType().identifier)

    let accountPackage = getAccount(account).getCapability(SimpleNFTMarketplace.PackagePublicPath)
                            .borrow<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>()
                            ?? panic("Could not borrow the public SimpleNFTMarketplace Package from account.")
    
    return accountPackage.borrowSaleCollectionPublic(tenantID: tenantID).getIDs()
}