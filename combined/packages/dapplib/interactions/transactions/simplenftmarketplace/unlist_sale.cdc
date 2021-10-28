import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: String, id: UInt64) {

    let SaleCollection: &SimpleNFTMarketplace.SaleCollection

    prepare(signer: AuthAccount) {

        let Package = signer.borrow<&SimpleNFTMarketplace.Package>(from: SimpleNFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.SaleCollection = Package.borrowSaleCollection(tenantID: tenantID)
    }

    execute {
        self.SaleCollection.unlistSale(id: id)
        log("Unlisted the NFT with id from Sale.")
    }
}

