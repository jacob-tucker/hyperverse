import Tribes from "../../../contracts/Project/Tribes.cdc"

pub fun main(tenantOwner: Address): String {
    let TenantPackage = getAccount(tenantOwner).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
    let TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
    return tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())
}