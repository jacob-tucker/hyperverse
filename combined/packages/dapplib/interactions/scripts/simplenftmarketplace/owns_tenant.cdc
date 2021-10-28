import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"

pub fun main(tenantOwner: Address): String {
    let TenantPackage = getAccount(tenantOwner).getCapability(SimpleNFTMarketplace.PackagePublicPath)
                                .borrow<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
    let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
    return tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
}