import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, id: UInt64) {

    let SaleCollection: &NFTMarketplace.SaleCollection

    prepare(signer: AuthAccount) {
        let Bundle = signer.borrow<&NFTMarketplace.Bundle>(from: NFTMarketplace.BundleStoragePath)
                        ?? panic("Could not borrow the signer's Bundle.")

        self.SaleCollection = Bundle.borrowSaleCollection(tenant: tenantOwner)
    }

    execute {
        self.SaleCollection.unlistSale(id: id)
        log("Unlisted the NFT with id from Sale.")
    }
}

