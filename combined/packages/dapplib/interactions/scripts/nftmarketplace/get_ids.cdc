import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

pub fun main(account: Address, tenantOwner: Address): [UInt64] {
    let TenantPackage = getAccount(tenantOwner).getCapability(NFTMarketplace.PackagePublicPath)
                                .borrow<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
    let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

    let accountPackage = getAccount(account).getCapability(NFTMarketplace.PackagePublicPath)
                            .borrow<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>()
                            ?? panic("Could not borrow the public NFTMarketplace Package from account.")
    
    return accountPackage.borrowSaleCollectionPublic(tenantID: TenantID).getIDs()
}