import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

pub fun main(tenantOwner: Address): String {
    // let TenantPackage = getAccount(tenantOwner).getCapability(SimpleNFT.PackagePublicPath)
    //                             .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
    //                             ?? panic("Could not borrow the public SimpleNFT.Package")
    // let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
    // return tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

    return SimpleNFT.getType().identifier
}