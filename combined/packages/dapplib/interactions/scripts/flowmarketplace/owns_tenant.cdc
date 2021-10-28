import FlowMarketplace from "../../../contracts/Project/FlowMarketplace.cdc"

pub fun main(tenantOwner: Address): String {
    let TenantPackage = getAccount(tenantOwner).getCapability(FlowMarketplace.PackagePublicPath)
                                .borrow<&FlowMarketplace.Package{FlowMarketplace.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
    let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
    return tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
}