import FlowMarketplace from "../../../contracts/Project/FlowMarketplace.cdc"

pub fun main(account: Address, tenantID: String): [UInt64] {

    let accountPackage = getAccount(account).getCapability(FlowMarketplace.PackagePublicPath)
                            .borrow<&FlowMarketplace.Package{FlowMarketplace.PackagePublic}>()
                            ?? panic("Could not borrow the public FlowMarketplace Package from account.")
    
    return accountPackage.borrowSaleCollectionPublic(tenantID: tenantID).getIDs()
}