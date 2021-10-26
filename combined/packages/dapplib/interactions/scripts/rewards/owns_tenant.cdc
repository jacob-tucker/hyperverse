import Rewards from "../../../contracts/Project/Rewards.cdc"

pub fun main(tenantOwner: Address): String {
    let TenantPackage = getAccount(tenantOwner).getCapability(Rewards.PackagePublicPath)
                                .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
    let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
    return tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
}