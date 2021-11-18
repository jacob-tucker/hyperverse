import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, id: UInt64, simpleNFTTenantOwner: Address) {

    let SaleCollection: &SimpleNFTMarketplace.SaleCollection

    prepare(signer: AuthAccount) {
        let Package = signer.borrow<&SimpleNFTMarketplace.Package>(from: SimpleNFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.SaleCollection = Package.borrowSaleCollection(tenant: tenantOwner)
    }

    execute {
        let simpleNFTTenantID = simpleNFTTenantOwner.toString()
                        .concat(".")
                        .concat(SimpleNFT.getType().identifier)
        self.SaleCollection.unlistSale(simpleNFTTenant: simpleNFTTenantOwner, id: id)
        log("Unlisted the NFT with id from Sale.")
    }
}

