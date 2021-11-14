import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

pub fun main(account: Address, tenantOwner: Address, simpleNFTTenantOwner: Address): [UInt64] {

    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleNFTMarketplace.getType().identifier)

    let accountPackage = getAccount(account).getCapability(SimpleNFTMarketplace.PackagePublicPath)
                            .borrow<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>()
                            ?? panic("Could not borrow the public SimpleNFTMarketplace Package from account.")
    
    let simpleNFTTenantID = simpleNFTTenantOwner.toString()
                        .concat(".")
                        .concat(SimpleNFT.getType().identifier)
    return accountPackage.borrowSaleCollectionPublic(tenantID: tenantID).getIDs(simpleNFTTenantID: simpleNFTTenantID)
}