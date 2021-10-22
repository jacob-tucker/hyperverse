import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: UInt64, id: UInt64) {

    let SaleCollection: &NFTMarketplace.SaleCollection

    prepare(signer: AuthAccount) {
        let Package = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.SaleCollection = Package.borrowSaleCollection(tenantID: tenantID)
    }

    execute {
        self.SaleCollection.unlistSale(id: id)
        log("Unlisted the NFT with id from Sale.")
    }
}

